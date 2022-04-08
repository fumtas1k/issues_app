require 'rails_helper'

RSpec.describe Issue, type: :model do
  describe "バリデーションのテスト" do
    let(:issue) { build(:issue) }
    shared_examples "バリデーションに引っかかる" do
      it {expect(issue).to_not be_valid}
    end

    context "必須事項を入力した場合" do
      it "バリデーションが通る" do
        expect(issue).to be_valid
      end
    end

    context "タイトルが空白の場合" do
      before {issue.title = ""}
      it_behaves_like "バリデーションに引っかかる"
    end

    context "タイトルが31文字の場合" do
      before {issue.title = "a" * 31}
      it_behaves_like "バリデーションに引っかかる"
    end

    context "詳細が空白の場合" do
      before {issue.description = ""}
      it_behaves_like "バリデーションに引っかかる"
    end

    context "公開範囲が空白の場合" do
      before {issue.scope = ""}
      it_behaves_like "バリデーションに引っかかる"
    end

    context "状態が空白の場合" do
      before {issue.status = ""}
      it_behaves_like "バリデーションに引っかかる"
    end
  end
end
