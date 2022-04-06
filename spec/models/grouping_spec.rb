require 'rails_helper'

RSpec.describe Grouping, type: :model do
  describe "バリデーションのテスト" do
    let(:mentor) { create(:mentor) }
    let(:user){ create(:user) }
    let!(:grouping) { create(:grouping, user: user, group: mentor.group) }
    let(:grouping2) { build(:grouping, user: user, group: mentor.group) }
    context "ユーザーとグループが同じ組み合わせでgroupingが2度作成された場合" do
      it "バリデーションに引っかかる" do
        expect(grouping2).not_to be_valid
      end
    end
  end
end
