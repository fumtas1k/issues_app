require 'rails_helper'
RSpec.describe :stock, type: :system do
  describe "ストック変更機能" do
    let!(:mentor) {create(:mentor)} # 最初の登録ユーザーがメンターになってしまうために用意
    let!(:author){create(:user)}
    let!(:user){create(:user, :seq)}
    let!(:issue){create(:issue, user: author)}

    describe "イシュー一覧画面" do
      context "他のユーザーのイシューのストックボタンを押した場合" do
        it "ストックされる" do
          sign_in user
          visit issues_path
          expect{
            find("#stock-btn-#{issue.id}").click
            sleep 0.1
          }.to change {issue.stocks.count}.by(1)
        end
      end

      context "ストックされたイシューのストックボタンを押した場合" do
        it "ストックが解除される" do
          FactoryBot.create(:stock, user: user, issue: issue)
          sign_in user
          visit issues_path
          expect{
            find("#stock-btn-#{issue.id}").click
            sleep 0.1
          }.to change {issue.stocks.count}.by(-1)
        end
      end

      context "著者がイシューのストックボタンを押した場合" do
        it "ストックされる" do
          sign_in author
          visit issues_path
          expect{
            find("#stock-btn-#{issue.id}").click
            sleep 0.1
          }.to change {issue.stocks.count}.by(1)
        end
      end
    end

    describe "イシュー詳細画面" do
      context "他のユーザーのイシューのストックボタンを押した場合" do
        it "ストックされる" do
          sign_in user
          visit issue_path(issue)
          expect{
            find("#stock-btn-#{issue.id}").click
            sleep 0.1
          }.to change {issue.stocks.count}.by(1)
        end
      end

      context "ストックされたイシューのストックボタンを押した場合" do
        it "ストックが解除される" do
          FactoryBot.create(:stock, user: user, issue: issue)
          sign_in user
          visit issue_path(issue)
          expect{
            find("#stock-btn-#{issue.id}").click
            sleep 0.1
          }.to change {issue.stocks.count}.by(-1)
        end
      end

      context "著者がイシューのストックボタンを押した場合" do
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
end
