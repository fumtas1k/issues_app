require 'rails_helper'

RSpec.describe "RailsAdmin", type: :request do
  let!(:target) { create(:user, :seq) }

  # CanCan::AccessDenied が例外になるか、レスポンスになるかは環境設定次第のため、どちらも拒否として扱う
  def request_allowed?(method, path, params: {})
    public_send(method, path, params: params)
    response.status == 200
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

    it "作成・更新・削除・エクスポート・一括削除は実行できない" do
      expect {
        request_allowed?(:post, "/admin/user", params: { user: attributes_for(:user, :seq, name: "created", code: "900099", email: "created@diver.com") })
        request_allowed?(:put, "/admin/user/#{target.id}", params: { user: { name: "changed" } })
        request_allowed?(:delete, "/admin/user/#{target.id}/delete")
        request_allowed?(:post, "/admin/user/bulk_delete", params: { bulk_action: "bulk_delete", bulk_ids: [target.id] })
        request_allowed?(:post, "/admin/user/export", params: { csv: true })
      }.not_to change { [User.count, target.reload.name] }
    end
  end

  context "非ゲストの管理者の場合" do
    before { sign_in create(:admin) }

    it "dashboard / index / show / new / edit / delete / export を開ける" do
      expect(request_allowed?(:get, "/admin")).to be true
      expect(request_allowed?(:get, "/admin/user")).to be true
      expect(request_allowed?(:get, "/admin/user/#{target.id}")).to be true
      expect(request_allowed?(:get, "/admin/user/new")).to be true
      expect(request_allowed?(:get, "/admin/user/#{target.id}/edit")).to be true
      expect(request_allowed?(:get, "/admin/user/#{target.id}/delete")).to be true
      expect(request_allowed?(:get, "/admin/user/export")).to be true
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
