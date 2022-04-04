require 'rails_helper'
RSpec.describe :user, type: :system do

  describe "アカウント登録機能" do
    before do
      visit new_user_registration_path
      fill_in "user_name", with: user_params[:name]
      fill_in "user_code", with: user_params[:code]
      fill_in "user_email", with: user_params[:email]
      fill_in "user_entered_at", with: user_params[:entered_at]
      fill_in "user_password", with: user_params[:password]
      fill_in "user_password_confirmation", with: user_params[:password]
      click_on "commit"
    end

    context "必須項目を全て入力してアカウント登録した場合" do
      let!(:user_params){attributes_for(:user)}
      it "サインアップできる" do
        expect(current_path).to eq user_path(User.last)
        expect(page).to have_content user_params[:email]
      end
    end

    context "パスワード関連を空白にしてアカウント登録した場合" do
      let!(:user_params){attributes_for(:user, password: "")}
      it "アカウント登録ページでエラーメッセージが表示される" do
        expect(current_path).to eq users_path
        expect(page).to have_content I18n.t("devise.registrations.new.sign_up")
        within "#error_explanation" do
          expect(page).to have_content I18n.t("errors.messages.blank"), count: 1
        end
      end
    end

    context "サインアップした状態でアカウント登録ページにアクセスしようとした場合" do
      let!(:user_params){attributes_for(:user)}
      it "rootページにリダイレクトしフラッシュが表示される" do
        visit new_user_registration_path
        expect(current_path).to eq root_path
        expect(page).to have_content I18n.t("devise.failure.already_authenticated")
      end
    end
  end
  describe "ログイン機能" do
    let!(:user){create(:user)}
    before do
      visit new_user_session_path
      fill_in "user_code", with: user_params[:code]
      fill_in "user_password", with: user_params[:password]
      click_on "commit"
    end
    context "必須項目を全て入力してログインした場合" do
      let!(:user_params){attributes_for(:user)}
      it "ログインできる" do
        expect(current_path).to eq user_path(User.last)
        expect(page).to have_content user_params[:email]
      end
    end

    context "パスワード関連を空白にしてログインした場合" do
      let!(:user_params){attributes_for(:user, password: "")}
      it "ログインページでエラーメッセージが表示される" do
        expect(current_path).to eq new_user_session_path
        expect(page).to have_content I18n.t("devise.sessions.new.sign_in")
        within ".alert-danger" do
          expect(page).to have_content User.human_attribute_name(:password)
        end
      end
    end
  end
end
