require 'rails_helper'

RSpec.describe "RailsAdmin", type: :request do
  let!(:target) { create(:user, :seq) }
  let(:new_user_params) do
    { name: "created", code: "900099", email: "created@diver.com", entered_at: "2020-04-01",
      password: "password", password_confirmation: "password" }
  end

  # 200 を返したら true。CanCan::AccessDenied が例外になるか、レスポンスになるかは環境設定次第のため、
  # どちらも拒否(false)として扱う。ActionController::RoutingError は rescue せず落とす。
  def request_allowed?(method, path, params: {})
    public_send(method, path, params: params)
    response.status == 200
  rescue CanCan::AccessDenied
    false
  end

  # 更新系は 302(成功時のリダイレクト)も成功として扱う
  def request_succeeded?(method, path, params: {})
    public_send(method, path, params: params)
    [200, 302].include?(response.status)
  rescue CanCan::AccessDenied
    false
  end

  context "ゲスト管理者の場合" do
    before { sign_in User.guest_admin_user }

    it "dashboard / index / show は見られる" do
      expect(request_allowed?(:get, "/admin")).to be true
      expect(request_allowed?(:get, "/admin/user")).to be true
      expect(request_allowed?(:get, "/admin/user/#{target.id}")).to be true
    end

    it "new / edit / delete / export は開けない" do
      expect(request_allowed?(:get, "/admin/user/new")).to be false
      expect(request_allowed?(:get, "/admin/user/#{target.id}/edit")).to be false
      expect(request_allowed?(:get, "/admin/user/#{target.id}/delete")).to be false
      expect(request_allowed?(:get, "/admin/user/export")).to be false
    end

    it "作成できない" do
      allowed = nil
      expect {
        allowed = request_succeeded?(:post, "/admin/user/new", params: { user: new_user_params })
      }.not_to change(User, :count)
      expect(allowed).to be false
    end

    it "更新できない" do
      allowed = nil
      expect {
        allowed = request_succeeded?(:put, "/admin/user/#{target.id}/edit", params: { user: { name: "changed" } })
      }.not_to change { target.reload.name }
      expect(allowed).to be false
    end

    it "削除できない" do
      allowed = nil
      expect {
        allowed = request_succeeded?(:delete, "/admin/user/#{target.id}/delete")
      }.not_to change(User, :count)
      expect(allowed).to be false
    end

    it "一括削除できない" do
      allowed = nil
      expect {
        allowed = request_succeeded?(:delete, "/admin/user/bulk_delete", params: { bulk_ids: [target.id] })
      }.not_to change(User, :count)
      expect(allowed).to be false
    end

    it "エクスポートできない" do
      expect(request_allowed?(:post, "/admin/user/export", params: { csv: true, all: true })).to be false
    end

    it "HTML 以外の形式では取得できない" do
      [
        "/admin/user.json",
        "/admin/user.json?all=true&send_data=true",
        "/admin/user.xml",
        "/admin/user.csv",
        "/admin/user/#{target.id}.json"
      ].each do |path|
        expect(request_allowed?(:get, path)).to be(false), "#{path} が取得できてしまう"
      end
    end
  end

  context "非ゲストの管理者の場合" do
    let!(:admin) { create(:admin) }
    before { sign_in admin }

    it "dashboard / index / show / new / edit / delete / export を開ける" do
      expect(request_allowed?(:get, "/admin")).to be true
      expect(request_allowed?(:get, "/admin/user")).to be true
      expect(request_allowed?(:get, "/admin/user/#{target.id}")).to be true
      expect(request_allowed?(:get, "/admin/user/new")).to be true
      expect(request_allowed?(:get, "/admin/user/#{target.id}/edit")).to be true
      expect(request_allowed?(:get, "/admin/user/#{target.id}/delete")).to be true
      expect(request_allowed?(:get, "/admin/user/export")).to be true
    end

    it "実際に更新できる(拒否 spec の対照)" do
      expect {
        request_succeeded?(:put, "/admin/user/#{target.id}/edit", params: { user: { name: "changed" } })
      }.to change { target.reload.name }.to("changed")
    end

    it "実際に作成できる" do
      expect {
        request_succeeded?(:post, "/admin/user/new", params: { user: new_user_params })
      }.to change(User, :count).by(1)
    end

    it "実際に削除できる" do
      expect {
        request_succeeded?(:delete, "/admin/user/#{target.id}/delete")
      }.to change(User, :count).by(-1)
    end

    it "json でも取得できる" do
      expect(request_allowed?(:get, "/admin/user.json")).to be true
      expect(request_allowed?(:get, "/admin/user/#{target.id}.json")).to be true
    end

    it "一覧に認証情報が表示されない" do
      get "/admin/user"
      expect(response.body).not_to include(target.encrypted_password)
    end
  end

  context "メンターの場合" do
    before { sign_in create(:mentor) }

    it "dashboard を開けない" do
      expect(request_allowed?(:get, "/admin")).to be false
    end
  end
end
