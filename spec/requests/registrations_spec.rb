require 'rails_helper'

RSpec.describe "Users::Registrations", type: :request do
  let(:avatar_file) { Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/images/avatar.jpg"), "image/jpeg") }

  describe "POST /users (sign_up)" do
    it "mentor / admin を送っても反映されない" do
      expect {
        post user_registration_path, params: {
          user: {
            name: "newuser", code: "900010", email: "new@diver.com", entered_at: "2020-04-01",
            password: "password", password_confirmation: "password",
            mentor: "1", admin: "1"
          }
        }
      }.to change(User, :count).by(1)
      created = User.find_by(code: "900010")
      expect(created.mentor).to be false
      expect(created.admin).to be false
    end
  end

  describe "PUT /users (account_update)" do
    let!(:user) { create(:user) }
    before { sign_in user }

    it "mentor / admin を送っても反映されない" do
      put user_registration_path, params: {
        user: { name: "renamed", current_password: "password", mentor: "1", admin: "1" }
      }
      user.reload
      expect(user.name).to eq "renamed"
      expect(user.mentor).to be false
      expect(user.admin).to be false
      expect(user.group).to be_nil
    end

    it "mentor=true のクエリパラメータでも他人のメンターは切り替わらない" do
      other = create(:user, :seq)
      put user_registration_path(mentor: true, user_id: other.id), params: {
        user: { current_password: "password" }
      }
      expect(other.reload.mentor).to be false
    end
  end

  describe "アバター更新" do
    let!(:user) { create(:user) }
    let!(:other) { create(:user, :seq) }
    before { sign_in user }

    it "user_id に他人を指定しても current_user のアバターが更新される" do
      patch user_registration_path(avatar: true, user_id: other.id), params: { user: { avatar: avatar_file } }
      expect(user.reload.avatar).to be_attached
      expect(other.reload.avatar).not_to be_attached
      expect(response).to redirect_to(edit_user_registration_path)
    end
  end

  describe "ゲストユーザー" do
    shared_examples "ゲストは変更できない" do
      it "プロフィールを更新できない" do
        expect {
          put user_registration_path, params: { user: { name: "renamed", current_password: "password" } }
        }.not_to change { guest.reload.name }
        expect(response).to redirect_to(user_path(guest))
      end

      it "アバターを変更できない" do
        patch user_registration_path(avatar: true), params: { user: { avatar: avatar_file } }
        expect(guest.reload.avatar).not_to be_attached
        expect(response).to redirect_to(user_path(guest))
      end

      it "編集ページを開けない" do
        get edit_user_registration_path
        expect(response).to redirect_to(user_path(guest))
      end

      it "退会できない" do
        guest
        expect {
          delete user_registration_path
        }.not_to change(User, :count)
        expect(response).to redirect_to(user_path(guest))
      end
    end

    context "ゲストユーザー" do
      let(:guest) { User.guest_user }
      before { sign_in guest }
      it_behaves_like "ゲストは変更できない"
    end

    context "ゲスト管理者" do
      let(:guest) { User.guest_admin_user }
      before { sign_in guest }
      it_behaves_like "ゲストは変更できない"
    end
  end
end
