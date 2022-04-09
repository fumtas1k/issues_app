require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe "バリデーションのテスト" do
    let!(:mentor) { create(:mentor) }
    let!(:user) { create(:user) }
    let!(:issue) { create(:issue, user: user) }
    let!(:comment) { build(:comment, user: mentor, issue: issue)}

    context "必須事項を入力した場合" do
      it "バリデーションが通る" do
        expect(comment).to be_valid
      end
    end

    context "内容を未入力にした場合" do
      it "バリデーションに引っかかる" do
        comment.content = ""
        expect(comment).not_to be_valid
      end
    end
  end
end
