require 'rails_helper'

RSpec.describe "Users::MentorRoles", type: :request do
  let!(:target) { create(:user, :seq) }

  describe "PATCH /users/:user_id/mentor_role" do
    context "非ゲストの管理者の場合" do
      let!(:admin) { create(:admin) }
      before { sign_in admin }

      it "一般ユーザーをメンターに切り替えられる" do
        expect {
          patch user_mentor_role_path(target)
        }.to change { target.reload.mentor }.from(false).to(true)
        expect(response).to redirect_to(users_path)
      end

      it "メンターを一般ユーザーに切り替えられる" do
        target.update!(mentor: true)
        expect {
          patch user_mentor_role_path(target)
        }.to change { target.reload.mentor }.from(true).to(false)
      end

      it "jsリクエストでも切り替えられる" do
        expect {
          patch user_mentor_role_path(target), xhr: true
        }.to change { target.reload.mentor }.to(true)
        expect(response).to have_http_status(:ok)
      end

      it "他の管理者は切り替えられない" do
        other_admin = create(:user, :seq, admin: true, mentor: true)
        expect {
          patch user_mentor_role_path(other_admin)
        }.not_to change { other_admin.reload.mentor }
        expect(response).to redirect_to(root_path)
      end

      it "ゲストユーザー・ゲスト管理者は切り替えられない" do
        [User.guest_user, User.guest_admin_user].each do |guest|
          expect {
            patch user_mentor_role_path(guest)
          }.not_to change { guest.reload.mentor }
          expect(response).to redirect_to(root_path)
        end
      end
    end

    shared_examples "切り替えられない" do
      it "メンターは変更されず、ルートパスにリダイレクトする" do
        expect {
          patch user_mentor_role_path(target)
        }.not_to change { target.reload.mentor }
        expect(response).to redirect_to(root_path)
      end

      it "jsリクエストでは403になる" do
        expect {
          patch user_mentor_role_path(target), xhr: true
        }.not_to change { target.reload.mentor }
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "非管理者のメンターの場合" do
      before { sign_in create(:mentor) }
      it_behaves_like "切り替えられない"
    end

    context "一般ユーザーの場合" do
      before { sign_in create(:user) }
      it_behaves_like "切り替えられない"
    end

    context "ゲスト管理者の場合" do
      before { sign_in User.guest_admin_user }
      it_behaves_like "切り替えられない"
    end

    context "ゲストユーザーの場合" do
      before { sign_in User.guest_user }
      it_behaves_like "切り替えられない"
    end

    context "未ログインの場合" do
      it "メンターは変更されず、ログインページにリダイレクトする" do
        expect {
          patch user_mentor_role_path(target)
        }.not_to change { target.reload.mentor }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
