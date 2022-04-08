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

  describe "マイページ機能" do
    let!(:user) {create(:user)}
    let!(:other_user) {create(:user, :seq)}
    before { sign_in user }

    context "自分のマイページにアクセスした場合" do
      it "アクセス出来る" do
        visit user_path(user)
        expect(current_path).to eq user_path(user)
        expect(page).to have_content user.code
      end
    end

    context "他人のマイページにアクセスした場合" do
      it "アクセス出来ず、ルートパスにリダイレクトする" do
        visit user_path(other_user)
        expect(current_path).to eq root_path
        expect(page).not_to have_content user.code
      end
    end
  end

  describe "メンター変更機能" do
    let!(:mentor){create(:mentor, admin: true)}
    let!(:user){create(:user, :seq)}

    context "メンターが他の非メンターの役割ボタンを押した場合" do
      it "メンターに変更される" do
        sign_in mentor
        visit users_path
        expect{
          find("#btn-role-#{user.id}").click
          sleep 0.1
          user.reload
        }.to change{user.mentor}.to(true)
      end
    end

    context "メンターが他のメンターの役割ボタンを押した場合" do
      it "非メンターに変更される" do
        user.update(mentor: true)
        sign_in mentor
        visit users_path
        expect{
          find("#btn-role-#{user.id}").click
          sleep 0.1
          user.reload
        }.to change{user.mentor}.to(false)
      end
    end
  end

  describe "管理者機能" do
    let!(:admin){create(:admin)}
    let!(:user){create(:user, :seq)}

    context "管理者がサイト管理にアクセスした場合" do
      it "アクセスできる" do
        sign_in admin
        visit rails_admin_path
        expect(page).to have_content I18n.t("admin.actions.dashboard.menu"), count: 3
      end
    end

    context "非管理者がサイト管理にアクセスした場合" do
      it "エラーページが表示される" do
        sign_in user
        visit rails_admin_path
        expect(page).to have_content "CanCan::AccessDenied"
      end
    end
  end

  describe "ゲストログイン機能" do
    context "ゲスト管理者ログインボタンを押した場合" do
      it "管理者としてログインできる" do
        visit root_path
        click_on I18n.t("devise.sessions.new.guest_admin_sign_in")
        expect(page).to have_content User.where(admin: true).last.name
      end
    end

    context "ゲスト管理者ログインボタンを押した後ログアウトし再度ログインした場合" do
      it "管理者としてログインできる" do
        visit root_path
        click_on I18n.t("devise.sessions.new.guest_admin_sign_in")
        click_on I18n.t("devise.sessions.new.sign_out")
        click_on I18n.t("devise.sessions.new.guest_admin_sign_in")
        expect(page).to have_content User.where(admin: true).last.name
      end
    end

    context "ゲストログインボタンを押した場合" do
      it "ゲストとしてログインできる" do
        visit root_path
        click_on I18n.t("devise.sessions.new.guest_sign_in")
        expect(page).to have_content User.where(admin: false).last.name
      end
    end

    context "ゲストログインボタンを押した後ログアウトし再度ログインした場合" do
      it "ゲストとしてログインできる" do
        visit root_path
        click_on I18n.t("devise.sessions.new.guest_sign_in")
        click_on I18n.t("devise.sessions.new.sign_out")
        click_on I18n.t("devise.sessions.new.guest_sign_in")
        expect(page).to have_content User.where(admin: false).last.name
      end
    end
  end
end
