require 'rails_helper'

RSpec.describe Stock, type: :model do
  describe "バリデーションのテスト" do
    let(:user) { create(:user) }
    let(:issue){ create(:issue_rand) }
    let!(:stock) { create(:stock, user: user, issue: issue) }
    let(:stock2) { build(:stock, user: user, issue: issue) }
    context "ユーザーとイシューが同じ組み合わせでいいねが2度作成された場合" do
      it "バリデーションに引っかかる" do
        expect(stock2).not_to be_valid
      end
    end
  end

  describe "コールバックのテスト" do
    let!(:user) { create(:user) }
    let!(:other) { create(:user, :seq) }
    let!(:issue) { create(:issue_rand, user: user) }
    let!(:stock) { build(:stock, user: user, issue: issue ) }
    let!(:stock_other) { build(:stock, user: other, issue: issue) }
    context "自分のイシューをストックした場合" do
      it "通知は作成されない" do
        expect{stock.save}.not_to change{Notification.count}
      end
    end

    context "他人がイシューをストックした場合" do
      it "自分に通知が作成される" do
        expect{
          stock_other.save
          expect(Notification.last.user).to eq user
        }.to change{Notification.count}.by(1)
      end
    end
  end
end
