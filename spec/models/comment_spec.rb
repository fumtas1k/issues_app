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

  context "内容の添付ファイルが5MB以下の場合" do
    pending "ファイルの添付方法不明のため保留"
    # it "バリデーションが通る" do
    #   comment.description = fixture_file_upload("/images/sample.jpg")
    #   expect(comment).to be_valid
    # end
  end

  context "内容の添付ファイルが5MBを超える場合" do
    pending "ファイルの添付方法不明のため保留"
    # before {comment.description.body = fixture_file_upload("/images/nature6.5MB.jpg")}
    # it_behaves_like "バリデーションに引っかかる"
  end

  describe "コールバックのテスト" do
    let!(:user) { create(:user) }
    let!(:other) { create(:user, :seq) }
    let!(:issue) { create(:issue_rand, user: user) }
    let!(:comment) { build(:comment, user: user, issue: issue) }
    let!(:comment_other) { build(:comment, user: other, issue: issue) }
    context "自分のイシューにコメントした場合" do
      it "通知は作成されない" do
        expect{comment.save}.not_to change(Notification, :count)
      end
    end

    context "他人がイシューにコメントした場合" do
      it "自分に通知が作成される" do
        expect{
          comment_other.save
          expect(Notification.last.user).to eq user
        }.to change{Notification.count}.by(1)
      end
    end
  end
end
