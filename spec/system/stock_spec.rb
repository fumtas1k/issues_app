require 'rails_helper'
RSpec.describe :stock, type: :system do
  describe "ストック変更機能" do
    let!(:author){create(:user)}
    let!(:user){create(:user, :seq)}
    let!(:issue){create(:issue, user: author)}

    context "イシュー一覧画面で他のユーザーのイシューのストックボタンを押した場合" do
      it "ストックされる" do
        sign_in user
        visit issues_path
        expect{
          find("#stock-btn-#{issue.id}").click
          sleep 0.1
        }.to change {issue.stocks.count}.by(1)
      end
    end

    context "イシュー一覧画面で著者がイシューのストックボタンを押した場合" do
      it "ストックされる" do
        sign_in author
        visit issues_path
        expect{
          find("#stock-btn-#{issue.id}").click
          sleep 0.1
        }.to change {issue.stocks.count}.by(1)
      end
    end

    context "イシュー詳細画面で他のユーザーのイシューのストックボタンを押した場合" do
      it "ストックされる" do
        sign_in user
        visit issue_path(issue)
        expect{
          find("#stock-btn-#{issue.id}").click
          sleep 0.1
        }.to change {issue.stocks.count}.by(1)
      end
    end

    context "イシュー詳細画面で著者がイシューのストックボタンを押した場合" do
      it "ストックされる" do
        sign_in author
        visit issue_path(issue)
        expect{
          find("#stock-btn-#{issue.id}").click
          sleep 0.1
        }.to change {issue.stocks.count}.by(1)
      end
    end
  end
end
