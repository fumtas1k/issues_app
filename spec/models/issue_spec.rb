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

    context "詳細の添付ファイルが5MB以下の場合" do
      pending "ファイルの添付方法不明のため保留"
      # it "バリデーションが通る" do
      #   issue.description = fixture_file_upload("/images/sample.jpg")
      #   expect(issue).to be_valid
      # end
    end

    context "詳細の添付ファイルが5MBを超える場合" do
      pending "ファイルの添付方法不明のため保留"
      # before {issue.description.body = fixture_file_upload("/images/nature6.5MB.jpg")}
      # it_behaves_like "バリデーションに引っかかる"
    end
  end
end
