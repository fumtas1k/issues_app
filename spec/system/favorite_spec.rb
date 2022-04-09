require 'rails_helper'
RSpec.describe :favorite, type: :system do
  describe "いいね変更機能" do
    let!(:mentor) {create(:mentor)} # 最初の登録ユーザーがメンターになってしまうために用意
    let!(:author){create(:user)}
    let!(:user){create(:user, :seq)}
    let!(:issue){create(:issue, user: author)}

    describe "イシュー一覧画面" do
      context "他のユーザーのイシューのいいねボタンを押した場合" do
        it "いいねがされる" do
          sign_in user
          visit issues_path
          expect{
            find("#favorite-btn-#{issue.id}").click
            sleep 0.1
          }.to change {issue.favorites.count}.by(1)
        end
      end

      context "いいねされたイシューのいいねボタンを押した場合" do
        it "いいねが解除される" do
          FactoryBot.create(:favorite, user: user, issue: issue)
          sign_in user
          visit issues_path
          expect{
            find("#favorite-btn-#{issue.id}").click
            sleep 0.1
          }.to change {issue.favorites.count}.by(-1)
        end
      end

      # イシュー著者にはいいねボタンを表示しない設定にした場合はこのテストを消すこと
      context "著者がイシューのいいねボタンを押した場合" do
        it "いいねされない" do
          sign_in author
          visit issues_path
          expect{
            find("#favorite-btn-#{issue.id}").click
            sleep 0.1
          }.not_to change {issue.favorites.count}
        end
      end
    end

    describe "イシュー詳細画面" do
      context "他のユーザーのイシューのいいねボタンを押した場合" do
        it "いいねがされる" do
          sign_in user
          visit issue_path(issue)
          expect{
            find("#favorite-btn-#{issue.id}").click
            sleep 0.1
          }.to change {issue.favorites.count}.by(1)
        end
      end

      context "いいねされたイシューのいいねボタンを押した場合" do
        it "いいねが解除される" do
          FactoryBot.create(:favorite, user: user, issue: issue)
          sign_in user
          visit issues_path
          expect{
            find("#favorite-btn-#{issue.id}").click
            sleep 0.1
          }.to change {issue.favorites.count}.by(-1)
        end
      end

      # イシュー著者にはいいねボタンを表示しない設定にした場合はこのテストを消すこと
      context "著者がイシューのいいねボタンを押した場合" do
        it "いいねされない" do
          sign_in author
          visit issue_path(issue)
          expect{
            find("#favorite-btn-#{issue.id}").click
            sleep 0.1
          }.not_to change {issue.favorites.count}
        end
      end
    end
  end
end
