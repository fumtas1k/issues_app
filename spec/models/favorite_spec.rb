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
end
