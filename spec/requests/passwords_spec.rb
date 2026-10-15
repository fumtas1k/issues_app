require 'rails_helper'

RSpec.describe "Users::Passwords", type: :request do
  describe "POST /users/password" do
    [:guest_user, :guest_admin_user].each do |guest_method|
      it "#{guest_method} のメールアドレスでは再設定を要求できない" do
        guest = User.public_send(guest_method)
        expect {
          post user_password_path, params: { user: { email: guest.email } }
        }.not_to change { ActionMailer::Base.deliveries.size }
        expect(response).to redirect_to(new_user_password_path)
        expect(guest.reload.reset_password_token).to be_nil
      end
    end
  end

  describe "PUT /users/password" do
    it "ゲストのパスワードは再設定トークンがあっても変更できない" do
      guest = User.guest_user
      # メール送信を伴わずにトークンだけ用意する
      raw_token = guest.send(:set_reset_password_token)
      encrypted_before = guest.reload.encrypted_password
      put user_password_path, params: {
        user: { reset_password_token: raw_token, password: "newpassword", password_confirmation: "newpassword" }
      }
      expect(guest.reload.encrypted_password).to eq encrypted_before
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
