require 'rails_helper'
RSpec.describe :notification, type: :system do
  let!(:mentor) { create(:mentor) }
  let!(:other_mentor) { create(:user, :seq, mentor: true) }
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user, :seq) }
  let!(:group) { create(:group, user: mentor) }
  let!(:grouping) { create(:grouping, user: user, group: group) }

  describe "commentの通知機能" do
    let!(:issue) { create(:issue, user: user) }
    let!(:comment_content) { attributes_for(:comment)[:content]}

    context "自分のイシューに自分がコメントした場合" do
      before do
        sign_in user
        visit issue_path(issue)
        fill_in_rich_text_area "comment_content", with: comment_content
        click_on I18n.t("helpers.submit.create")
      end
      it "通知は作成されない" do
        expect(Notification.count).to eq 0
      end
    end

    context "自分のイシューに他人がコメントした場合" do
      before do
        sign_in other_user
        visit issue_path(issue)
        fill_in_rich_text_area "comment_content", with: comment_content
        click_on I18n.t("helpers.submit.create")
      end

      it "他人には通知が表示されない" do
        visit user_notifications_path(other_user)
        expect(page).not_to have_css ".notification-link"
      end

      it "自分に通知が表示される" do
        click_on I18n.t("devise.sessions.new.sign_out")
        sign_in user
        visit user_notifications_path(user)
        expect(page).to have_css ".notification-link"
        expect(page).to have_content Comment.human_attribute_name(:notify_message, user: other_user.name,issue: issue.title)
      end
    end
  end

  describe "favoriteの通知機能" do
    let!(:issue) { create(:issue, user: user) }

    context "自分のイシューに他人がいいねした場合" do
      before do
        sign_in other_user
        visit issue_path(issue)
        find("#favorite-btn-#{issue.id}").click
      end

      it "他人には通知が表示されない" do
        visit user_notifications_path(other_user)
        expect(page).not_to have_css ".notification-link"
      end

      it "自分に通知が表示される" do
        click_on I18n.t("devise.sessions.new.sign_out")
        sign_in user
        visit user_notifications_path(user)
        expect(page).to have_css ".notification-link"
        expect(page).to have_content Favorite.human_attribute_name(:notify_message, user: other_user.name,issue: issue.title)
      end
    end
  end

  describe "issueの通知機能" do
    before do
      sign_in user
      visit link_path
      fill_in "issue_title", with: issue_params[:title]
      select Issue.human_enum_status(issue_params[:status]), from: Issue.human_attribute_name(:status)
      select Issue.human_enum_scope(issue_params[:scope]), from: Issue.human_attribute_name(:scope)
      fill_in_rich_text_area "issue_description", with: issue_params[:description]
      fill_in("vue-tag-input", with: issue_params[:tag_list], visible: false).send_keys :return
      click_on click_btn
    end

    context "イシューを投稿した場合" do
      let(:link_path) { new_issue_path }
      let(:issue_params) { attributes_for(:issue) }
      let(:click_btn) { I18n.t("helpers.submit.create") }

      it "自分に通知が表示されない" do
        visit user_notifications_path(user)
        expect(page).not_to have_css ".notification-link"
      end

      it "他人に通知が表示されない" do
        click_on I18n.t("devise.sessions.new.sign_out")
        sign_in other_user
        visit user_notifications_path(other_user)
        expect(page).not_to have_css ".notification-link"
      end

      it "担当メンターに通知が表示される" do
        click_on I18n.t("devise.sessions.new.sign_out")
        sign_in mentor
        visit user_notifications_path(mentor)
        expect(page).to have_css ".notification-link"
        expect(page).to have_content Issue.human_attribute_name(:notify_message, user: user.name,issue: issue_params[:title])
      end

      it "担当外メンターに通知が表示されない" do
        click_on I18n.t("devise.sessions.new.sign_out")
        sign_in other_mentor
        visit user_notifications_path(other_mentor)
        expect(page).not_to have_css ".notification-link"
      end
    end

    context "下書きのイシューを投稿した場合" do
      let(:link_path) { new_issue_path }
      let(:issue_params) { attributes_for(:issue, :draft) }
      let(:click_btn) { I18n.t("helpers.submit.create") }

      it "通知が生成されない" do
        expect(Notification.count).to eq 0
      end
    end

    context "イシューのstatusを解決に更新した場合" do
      let!(:issue) { create(:issue_rand, :release, status: "pending", user: user) }
      let(:link_path) { edit_issue_path(issue) }
      let(:issue_params) { attributes_for(:issue, status: "solving") }
      let(:click_btn) { I18n.t("helpers.submit.update") }

      it "自分に通知が表示されない" do
        visit user_notifications_path(user)
        expect(page).not_to have_css ".notification-link"
      end

      it "他人に通知が表示されない" do
        click_on I18n.t("devise.sessions.new.sign_out")
        sign_in other_user
        visit user_notifications_path(other_user)
        expect(page).not_to have_css ".notification-link"
      end

      it "担当メンターに通知が表示される" do
        click_on I18n.t("devise.sessions.new.sign_out")
        sign_in mentor
        visit user_notifications_path(mentor)
        expect(page).to have_css ".notification-link"
        expect(page).to have_content Issue.human_attribute_name(:solving_notify_message, user: user.name,issue: issue_params[:title])
      end

      it "担当外メンターに通知が表示されない" do
        click_on I18n.t("devise.sessions.new.sign_out")
        sign_in other_mentor
        visit user_notifications_path(other_mentor)
        expect(page).not_to have_css ".notification-link"
      end
    end
  end

  describe "stockの通知機能" do
    let!(:issue) { create(:issue, user: user) }

    context "自分のイシューを自分がストックした場合" do
      before do
        sign_in user
        visit issue_path(issue)
        find("#stock-btn-#{issue.id}").click
      end

      it "自分に通知が表示されない" do
        visit user_notifications_path(user)
        expect(page).not_to have_css ".notification-link"
      end

      it "他人には通知が表示されない" do
        click_on I18n.t("devise.sessions.new.sign_out")
        sign_in other_user
        visit user_notifications_path(other_user)
        expect(page).not_to have_css ".notification-link"
      end
    end

    context "自分のイシューを他人がストックした場合" do
      before do
        sign_in other_user
        visit issue_path(issue)
        find("#stock-btn-#{issue.id}").click
      end

      it "他人には通知が表示されない" do
        visit user_notifications_path(other_user)
        expect(page).not_to have_css ".notification-link"
      end

      it "自分に通知が表示される" do
        click_on I18n.t("devise.sessions.new.sign_out")
        sign_in user
        visit user_notifications_path(user)
        expect(page).to have_css ".notification-link"
        expect(page).to have_content Stock.human_attribute_name(:notify_message, user: other_user.name,issue: issue.title)
      end
    end
  end

  describe "通知の既読機能" do
    let!(:issue) { create(:issue, user: user) }
    let!(:other_issue) { create(:issue, user: other_user) }
    let(:comment_params) { attributes_for(:comment) }
    before do
      sign_in other_user
      visit issue_path(issue)
      click_on "bookmark_border"
      click_on "favorite_border"
      fill_in_rich_text_area "comment_content", with: comment_params[:content]
      click_on I18n.t("helpers.submit.create")
      click_on I18n.t("devise.sessions.new.sign_out")

      sign_in user
      visit issue_path(other_issue)
      click_on "bookmark_border"
      visit user_notifications_path(user)
    end

    context "未読の通知をクリックした場合" do
      before do
        all(".notification-container").first.click
      end

      it "通知のリンク先にリダイレクトする" do
        expect(current_path).to eq issue_path(issue)
      end

      it "その通知のみ既読になる" do
        visit user_notifications_path(user)
        expect(all(".unread").count).to eq 2
        expect(Notification.unreads.count).to eq 3
      end
    end

    context "既読の通知をクリックした場合" do
      before do
        all(".notification-container")[1].click
        visit user_notifications_path(user)
        all(".notification-container")[1].click
      end

      it "通知のリンク先にリダイレクトする" do
        expect(current_path).to eq issue_path(issue)
      end
      it "既読数は変化しない" do
        expect(Notification.unreads.count).to eq 3
      end
    end

    context "全既読ボタンをクリックした場合" do
      before do
        find(".read-all").click
      end
      it "自分の通知が全て既読になる" do
        expect(user.notifications.unreads.count).to eq 0
      end
      it "他人の通知は既読にならない" do
        expect(Notification.unreads.count).to eq 1
      end
    end
  end

end
