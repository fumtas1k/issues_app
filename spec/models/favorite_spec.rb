require 'rails_helper'

RSpec.describe Favorite, type: :model do
  describe "バリデーションのテスト" do
    let(:user) { create(:user) }
    let(:issue){ create(:issue_rand) }
    let!(:favorite) { create(:favorite, user: user, issue: issue) }
    let(:favorite2) { build(:favorite, user: user, issue: issue) }
    context "ユーザーとイシューが同じ組み合わせでいいねが2度作成された場合" do
      it "バリデーションに引っかかる" do
        expect(favorite2).not_to be_valid
      end
    end
  end

  describe "コールバックのテスト" do
    let!(:user) { create(:user) }
    let!(:other) { create(:user, :seq) }
    let!(:issue) { create(:issue_rand, user: user) }
    let!(:favorite) { build(:favorite, user: user, issue: issue) }
    let!(:favorite_other) { build(:favorite, user: other, issue: issue) }
    context "自分のイシューにいいねした場合" do
      it "通知は作成されない" do
        expect{favorite.save}.not_to change(Notification, :count)
      end
    end

    context "他人がイシューにいいねした場合" do
      it "自分に通知が作成される" do
        expect{
          favorite_other.save
          expect(Notification.last.user).to eq user
        }.to change(Notification, :count).by(1)
      end
    end
  end
end
