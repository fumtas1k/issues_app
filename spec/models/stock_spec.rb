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
end
