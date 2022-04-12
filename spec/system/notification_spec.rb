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
    context "イシューを投稿した場合" do
      let(:issue_params) { attributes_for(:issue) }
      before do
        sign_in user
        visit new_issue_path
        fill_in "issue_title", with: issue_params[:title]
        select Issue.human_enum_status(issue_params[:status]), from: Issue.human_attribute_name(:status)
        select Issue.human_enum_scope(issue_params[:scope]), from: Issue.human_attribute_name(:scope)
        fill_in_rich_text_area "issue_description", with: issue_params[:description]
        fill_in("vue-tag-input", with: issue_params[:tag_list], visible: false).send_keys :return
        click_on I18n.t("helpers.submit.create")
      end

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
    let!(:issue_read) { create(:issue_rand, user: user) }
    let!(:issue_unread) { create(:issue_rand, user: user) }
    let!(:favorite) { create(:favorite, user: other_user, issue: issue) }
    let!(:notification) { create(:notification, subject: issue, user: mentor, link_path: issue_path(issue))}
    let!(:notification_read) { create(:notification, subject: issue_read,  user: mentor, read: true, link_path: issue_path(issue_read))}
    let!(:notification_unread) { create(:notification, subject: issue_unread,  user: mentor, link_path: issue_path(issue_unread))}
    let!(:notification_favorite) { create(:notification, subject: issue, user: user, link_path: issue_path(issue))}
    before do
      sign_in mentor
      visit user_notifications_path(mentor)
    end

    context "未読の通知をクリックした場合" do
      before do
        find("#notification-link-#{notification.id}").click
      end

      it "通知のリンク先にリダイレクトする" do
        expect(current_path).to eq issue_path(issue)
      end

      it "その通知のみ既読になる" do
        expect(notification.reload.read).to be_truthy
        expect(notification_unread.reload.read).to be_falsy
        expect(notification_favorite.reload.read).to be_falsy
      end
    end
    context "既読の通知をクリックした場合" do
      before do
        find("#notification-link-#{notification_read.id}").click
      end

      it "通知のリンク先にリダイレクトする" do
        expect(current_path).to eq issue_path(issue_read)
      end
      it "既読数は変化しない" do
        expect(Notification.where(read: true).count).to eq 1
      end
    end

    context "全既読ボタンをクリックした場合" do
      before do
        find(".read-all").click
      end
      it "自分(mentor)の通知が全て既読になる" do
        expect(mentor.notifications.unreads.count).to eq 0
      end
      it "他人の通知は既読にならない" do
        expect(user.notifications.unreads.count).to eq 1
      end
    end
  end

end
