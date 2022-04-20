require 'rails_helper'

# モデルにて、最初に登録したユーザーを管理者兼メンター権限とする設定にしています。
# ご注意ください。
RSpec.describe :user, type: :system do

  describe "アカウント登録機能" do
    before do
      visit new_user_registration_path
      fill_in "user_name", with: user_params[:name]
      fill_in "user_code", with: user_params[:code]
      fill_in "user_email", with: user_params[:email]
      fill_in "user_entered_at", with: user_params[:entered_at]
      attach_file "user_avatar", user_params[:avatar]
      fill_in "user_password", with: user_params[:password]
      fill_in "user_password_confirmation", with: user_params[:password_confirmation]
      click_on "commit"
      sleep 0.2
    end

    context "必須項目を全て入力してアカウント登録した場合" do
      let!(:user_params){attributes_for(:user).merge({avatar: "#{Rails.root}/spec/fixtures/images/avatar.jpg"})}
      it "サインアップできる" do
        expect(current_path).to eq user_path(User.last)
        expect(page).to have_content user_params[:code]
      end
    end

    context "パスワード関連を空白にしてアカウント登録した場合" do
      let!(:user_params){attributes_for(:user, password: "").merge({avatar: "#{Rails.root}/spec/fixtures/images/avatar.jpg"})}
      it "アカウント登録ページでエラーメッセージが表示される" do
        expect(current_path).to eq new_user_registration_path
        expect(page).to have_content I18n.t("devise.registrations.new.subtitle")
      end
    end

    context "パスワードと確認用パスワードを異なる入力をしてアカウント登録した場合" do
      let!(:user_params){attributes_for(:user, password: "password", password_confirmation: "password".reverse).merge({avatar: "#{Rails.root}/spec/fixtures/images/avatar.jpg"})}
      it "アカウント登録ページにリダイレクトしエラーメッセージが表示される" do
        expect(current_path).to eq users_path
        expect(page).to have_content I18n.t("devise.registrations.new.subtitle")
        within "#error_explanation" do
          expect(page).to have_content I18n.t("errors.messages.confirmation", attribute: User.human_attribute_name(:password)), count: 1
        end
      end
    end

    context "バリデーションに引っかかった後、ファイルを添付せず修正し、正常に投稿した場合" do
      let!(:user_params){attributes_for(:user, password: "password", password_confirmation: "password".reverse).merge({avatar: "#{Rails.root}/spec/fixtures/images/avatar.jpg"})}
      before do
        fill_in "user_password", with: user_params[:password]
        fill_in "user_password_confirmation", with: user_params[:password]
        click_on "commit"
        sleep 0.1
      end
      it "avatarは正常に登録されている" do
        expect(current_path).to eq user_path(User.last)
        expect(User.last.avatar.blob.filename.to_s).to eq "avatar.jpg"
      end
    end

    context "サインアップした状態でアカウント登録ページにアクセスしようとした場合" do
      let!(:user_params){attributes_for(:user).merge({avatar: "#{Rails.root}/spec/fixtures/images/avatar.jpg"})}
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
    end
    context "必須項目を全て入力してログインした場合" do
      let!(:user_params){attributes_for(:user)}
      it "ログインできる" do
        click_on "commit"
        expect(current_path).to eq user_path(User.last)
        expect(page).to have_content user_params[:code]
      end
    end

    context "パスワード関連を空白にしてログインしようとした場合" do
      let!(:user_params){attributes_for(:user, password: "")}
      it "ログインボタンを押せない" do
        expect(page).to have_button "commit", disabled: true
      end
    end
  end

  describe "ユーザー編集機能" do
    let!(:user){create(:user, :seq)}
    before do
      sign_in user
      visit edit_user_registration_path(user)
      fill_in "user_name", with: user_params[:name]
      fill_in "user_code", with: user_params[:code]
      fill_in "user_email", with: user_params[:email]
      fill_in "user_entered_at", with: user_params[:entered_at]
      fill_in "user_current_password", with: user_params[:password]
      click_on "commit"
      sleep 0.1
    end

    context "パスワード変更以外入力し更新ボタンを押した場合" do
      let!(:user_params) { attributes_for(:user, name: "update_name", code: "upcode", email: "update@diver.com", entered_at: Date.new(2023,4,1), password: user.password) }

      it "マイページにリダイレクトし、入力したデータに更新される" do
        expect(current_path).to eq user_path(user)
        expect(page).to have_content user_params[:name], count: 2
        expect(page).to have_content user_params[:code]
        expect(page).to have_content user_params[:entered_at].year
      end
    end
  end

  describe "avatar編集機能" do
    let!(:user){create(:user, :seq)}
    before do
      sign_in user
      user.avatar = fixture_file_upload("/images/avatar.jpg")
      visit edit_avatar_user_path(user)
    end

    context "avatar編集ページでファイルを添付し更新ボタンを押した場合" do
      before do
        attach_file "user_avatar", "#{Rails.root}/app/assets/images/dummy_user.jpg"
      end
      it "編集ページにリダイレクトしavatarが変更される" do
        expect {
          page.accept_confirm { click_on "commit" }
          sleep 0.1
          expect(current_path).to eq edit_user_registration_path(user)
        }.to change {User.last.avatar.blob.filename.to_s}.from("avatar.jpg").to("dummy_user.jpg")
      end
    end

    context "avatar編集ページでファイルを添付せずに更新ボタンを押した場合" do
      it "編集ページにリダイレクトしavatarが削除される" do
        expect {
          page.accept_confirm { click_on "commit" }
          sleep 0.1
          expect(current_path).to eq edit_user_registration_path(user)
        }.to change {User.last.avatar.attached?}.from(true).to(false)
      end
    end
  end

  describe "マイページ機能" do
    let!(:mentor) {create(:mentor)}
    let!(:user) {create(:user)}
    let!(:other_user) {create(:user, :seq)}
    let!(:release_issue) {create(:issue, user: user)}
    let!(:limited_issue) {create(:issue, :limited, user: user)}
    let!(:draft_issue) {create(:issue, :draft, user: user)}
    let!(:other_issue) {create(:issue_rand, user: other_user)}

    context "自分のマイページにアクセスした場合" do
      before do
        sign_in user
        visit user_path(user)
      end
      it "アクセス出来る" do
        expect(current_path).to eq user_path(user)
        expect(page).to have_content user.code
      end

      it "自分のイシューが全て表示されている" do
        expect(page).to have_content release_issue.title, count: 3
        expect(page).not_to have_content other_issue.title
      end
    end

    context "他人のマイページにアクセスした場合" do
      it "アクセス出来ず、ルートパスにリダイレクトする" do
        sign_in user
        visit user_path(other_user)
        expect(current_path).to eq root_path
        expect(page).not_to have_content user.code
      end
    end
  end

  describe "マイページ/メンター機能" do
    let!(:mentor) {create(:mentor)}
    let!(:user) {create(:user)}
    let!(:other_user) {create(:user, :seq)}
    let!(:release_issue) {create(:issue, user: user)}
    let!(:limited_issue) {create(:issue, :limited, user: user)}
    let!(:draft_issue) {create(:issue, :draft, user: user)}
    let!(:other_issue) {create(:issue_rand, user: other_user)}

    context "メンターがメンターページにアクセスした場合" do
      let!(:grouping) {create(:grouping, user: user, group: mentor.group)}
      before do
        sign_in mentor
        visit mentor_user_path(mentor)
      end
      it "アクセス出来る" do
        expect(current_path).to eq mentor_user_path(mentor)
        expect(page).to have_content mentor.code
      end

      it "自分のグループのメンバーの限定・公開のイシューが表示されている" do
        expect(page).to have_content release_issue.title, count: 2
        expect(page).not_to have_content other_issue.title
      end
    end

    context "非メンターがメンターページにアクセスした場合" do
      before do
        sign_in user
        visit mentor_user_path(mentor)
      end
      it "ルートパスにリダイレクトされる" do
        expect(current_path).to eq root_path
      end
    end
  end

  describe "マイページ/ストックページ機能" do
    let!(:mentor) {create(:mentor)} # 最初の登録ユーザーがメンターになってしまうために用意
    let!(:user) {create(:user)}
    let!(:other_user) {create(:user, :seq)}
    let!(:stock_issue1) {create(:issue_rand, :release, user: user)}
    let!(:stock_issue2) {create(:issue_rand, :release, user: other_user)}
    let!(:non_stock_issue) {create(:issue_rand, :release, user: other_user)}
    let!(:user_stock1) {create(:stock, user: user, issue: stock_issue1)}
    let!(:user_stock2) {create(:stock, user: user, issue: stock_issue2)}
    before { sign_in user }

    context "自分のマイページ/ストックページにアクセスした場合" do
      before { visit stocked_user_path(user) }
      it "アクセス出来る" do
        expect(current_path).to eq stocked_user_path(user)
        expect(page).to have_content user.code
      end

      it "ストックしたイシューのみ表示される" do
        expect(page).to have_content stock_issue1.title
        expect(page).to have_content stock_issue2.title
        expect(page).not_to have_content non_stock_issue.title
      end
    end

    context "他人のマイページ/ストックページにアクセスした場合" do
      it "アクセス出来ず、ルートパスにリダイレクトする" do
        visit stocked_user_path(other_user)
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
