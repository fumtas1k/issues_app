require 'rails_helper'

RSpec.describe Notification, type: :model do
  describe "バリデーションのテスト" do
    let(:notification){ build(:notification) }

    shared_examples "バリデーションに引っかかる" do
      it {expect(notification).to_not be_valid}
    end

    context "必要事項が全て入力されている場合" do
      it "バリデーションが通る" do
        expect(notification).to be_valid
      end
    end

    context "メッセージカラムが空の場合" do
      before{notification.message = ""}
      it_behaves_like "バリデーションに引っかかる"
    end

    context "リンク先カラムが空の場合" do
      before{notification.link_path = ""}
      it_behaves_like "バリデーションに引っかかる"
    end
  end
end
