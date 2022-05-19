require 'rails_helper'

RSpec.describe Message, type: :model do
  describe "バリデーションテスト" do
    let(:message) { build(:message) }
    context "全てを入力した場合" do
      it "バリデーションが通る" do
        expect(message).to be_valid
      end
    end

    context "contentを未入力にした場合" do
      it "バリデーションに引っかかる" do
        message.content = ""
        expect(message).not_to be_valid
      end
    end
  end
end
