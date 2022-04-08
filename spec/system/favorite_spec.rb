require 'rails_helper'
RSpec.describe :favorite, type: :system do
  describe "グルーピング変更機能" do
    let!(:author){create(:user)}
    let!(:user){create(:user, :seq)}
    let!(:issue){create(:issue, user: author)}

    context "イシュー一覧画面で他のユーザーのイシューのいいねボタンを押した場合" do
      it "いいねがされる" do
        sign_in user
        visit issues_path
        expect{
          find("#favorite-btn-#{issue.id}").click
          sleep 0.1
        }.to change {issue.favorites.count}.by(1)
      end
    end

    # イシュー著者にはいいねボタンを表示しない設定にした場合はこのテストを消すこと
    context "イシュー一覧画面で著者がイシューのいいねボタンを押した場合" do
      it "いいねされない" do
        sign_in author
        visit issues_path
        expect{
          find("#favorite-btn-#{issue.id}").click
          sleep 0.1
        }.not_to change {issue.favorites.count}
      end
    end

    context "イシュー詳細画面で他のユーザーのイシューのいいねボタンを押した場合" do
      it "いいねがされる" do
        sign_in user
        visit issue_path(issue)
        expect{
          find("#favorite-btn-#{issue.id}").click
          sleep 0.1
        }.to change {issue.favorites.count}.by(1)
      end
    end

    # イシュー著者にはいいねボタンを表示しない設定にした場合はこのテストを消すこと
    context "イシュー詳細画面で著者がイシューのいいねボタンを押した場合" do
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
