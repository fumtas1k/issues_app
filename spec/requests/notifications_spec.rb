require 'rails_helper'
RSpec.describe "Notifications", type: :request do
  let!(:mentor) { create(:mentor) } # 最初の登録ユーザーがメンターになってしまうために用意
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user, :seq) }
  let!(:issue) { create(:issue, user: user) }
  let!(:notification) { create(:notification, user: user, subject: issue, link_path: "/issues") }
  let!(:other_notification) { create(:notification, user: other_user, subject: issue, link_path: "/issues") }

  describe "GET /users/:user_id/notifications" do
    it "未ログインの場合はログイン画面にリダイレクトされる" do
      get user_notifications_path(user)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "自分の通知は表示できる" do
      sign_in user
      get user_notifications_path(user)
      expect(response).to have_http_status(:ok)
    end

    it "他人の通知は表示できない" do
      sign_in user
      get user_notifications_path(other_user)
      expect(response).to redirect_to(root_path)
    end
  end

  describe "PATCH /users/:user_id/notifications/:id" do
    it "未ログインの場合は既読にならない" do
      patch user_notification_path(user, notification)
      expect(response).to redirect_to(new_user_session_path)
      expect(notification.reload.read).to be false
    end

    it "自分の通知は既読になり、リンク先にリダイレクトされる" do
      sign_in user
      patch user_notification_path(user, notification)
      expect(notification.reload.read).to be true
      expect(response).to redirect_to("/issues")
    end

    it "他人の通知IDを自分のURLで指定しても既読にならない" do
      sign_in user
      expect {
        patch user_notification_path(user, other_notification)
      }.to raise_error(ActiveRecord::RecordNotFound)
      expect(other_notification.reload.read).to be false
    end

    it "他人のURLでは既読にならない" do
      sign_in user
      patch user_notification_path(other_user, other_notification)
      expect(response).to redirect_to(root_path)
      expect(other_notification.reload.read).to be false
    end
  end

  describe "PATCH /users/:user_id/notifications/read_all" do
    it "未ログインの場合は既読にならない" do
      patch read_all_user_notifications_path(user)
      expect(response).to redirect_to(new_user_session_path)
      expect(notification.reload.read).to be false
    end

    it "自分の通知だけが既読になる" do
      sign_in user
      patch read_all_user_notifications_path(user)
      expect(response).to redirect_to(user_notifications_path(user))
      expect(notification.reload.read).to be true
      expect(other_notification.reload.read).to be false
    end

    it "他人のURLでは誰の通知も既読にならない" do
      sign_in user
      patch read_all_user_notifications_path(other_user)
      expect(response).to redirect_to(root_path)
      expect(notification.reload.read).to be false
      expect(other_notification.reload.read).to be false
    end
  end

  describe "DELETE /users/:user_id/notifications/destroy_all" do
    it "未ログインの場合は削除されない" do
      expect {
        delete destroy_all_user_notifications_path(user)
      }.not_to change(Notification, :count)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "自分の通知だけが削除される" do
      sign_in user
      expect {
        delete destroy_all_user_notifications_path(user)
      }.to change { user.notifications.count }.from(1).to(0)
      expect(response).to redirect_to(user_notifications_path(user))
      expect(other_user.notifications.count).to eq 1
    end

    it "他人のURLでは誰の通知も削除されない" do
      sign_in user
      expect {
        delete destroy_all_user_notifications_path(other_user)
      }.not_to change(Notification, :count)
      expect(response).to redirect_to(root_path)
    end
  end
end
