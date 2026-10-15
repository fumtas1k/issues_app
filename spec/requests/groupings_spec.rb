require 'rails_helper'
RSpec.describe "Groupings", type: :request do
  let!(:mentor) { create(:mentor) } # 最初の登録ユーザーがメンターになってしまうために用意
  let!(:group) { ensure_group(mentor) }
  let!(:other_mentor) { create(:user, :seq, mentor: true) }
  let!(:other_group) { ensure_group(other_mentor) }
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user, :seq) }

  describe "POST /groupings" do
    it "未ログインの場合はログイン画面にリダイレクトされ、作成されない" do
      expect {
        post groupings_path, params: { member_id: user.id }
      }.not_to change(Grouping, :count)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "メンターでない場合は作成されない" do
      sign_in other_user
      expect {
        post groupings_path, params: { member_id: user.id }
      }.not_to change(Grouping, :count)
      expect(response).to redirect_to(root_path)
    end

    it "jsリクエストでも、メンターでなければ500にならず作成されない" do
      sign_in other_user
      expect {
        post groupings_path, params: { member_id: user.id }, xhr: true
      }.not_to change(Grouping, :count)
      expect(response).not_to have_http_status(:internal_server_error)
    end

    it "メンターの場合は自分のグループに追加される" do
      sign_in mentor
      expect {
        post groupings_path, params: { member_id: user.id }
      }.to change { group.groupings.count }.by(1)
      expect(response).to redirect_to(users_path)
      expect(other_group.groupings.count).to eq 0
    end
  end

  describe "DELETE /groupings/:id" do
    let!(:grouping) { create(:grouping, user: user, group: group) }
    let!(:other_grouping) { create(:grouping, user: other_user, group: other_group) }

    it "未ログインの場合は削除されない" do
      expect {
        delete grouping_path(grouping)
      }.not_to change(Grouping, :count)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "メンターでない場合は削除されない" do
      sign_in user
      expect {
        delete grouping_path(grouping)
      }.not_to change(Grouping, :count)
      expect(response).to redirect_to(root_path)
    end

    it "メンターは自分のグループのメンバーを削除できる" do
      sign_in mentor
      expect {
        delete grouping_path(grouping)
      }.to change { group.groupings.count }.by(-1)
      expect(response).to redirect_to(users_path)
    end

    it "メンターでも他のグループのメンバーは削除できない" do
      sign_in mentor
      expect {
        expect {
          delete grouping_path(other_grouping)
        }.to raise_error(ActiveRecord::RecordNotFound)
      }.not_to change(Grouping, :count)
    end
  end
end
