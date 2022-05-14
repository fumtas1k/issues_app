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

  describe "コールバックテスト" do
    let!(:mentor) { create(:mentor) }
    let!(:other_mentor) { create(:user, :seq, mentor: true) }
    let!(:user) { create(:user) }
    let!(:grouping) { create(:grouping, group: mentor.group, user: user)}
    let!(:other) { create(:user, :seq) }
    let!(:issue_release) { build(:issue_rand, :release, user: user) }
    let!(:issue_limited) { build(:issue_rand, :limited, user: user) }
    let!(:issue_draft) { build(:issue_rand, :draft, user: user) }
    context "ユーザーが公開イシューを投稿した場合" do
      it "担当メンターに通知が作成され、その他には通知されない" do
        expect{
          issue_release.save
          expect(mentor.notifications.count).to eq 1
          expect(other_mentor.notifications.count).to eq 0
          expect(user.notifications.count).to eq 0
          expect(other.notifications.count).to eq 0
        }.to change{Notification.count}.by(1)
      end
    end

    context "ユーザーが公開イシューを更新した場合" do
      it "通知はされない" do
        issue_release.save
        sleep 0.1
        expect{
          issue_release.update(title: "update")
        }.to change{Notification.count}.by(0)
      end
    end

    context "ユーザーが公開イシューを何も変更せず更新した場合" do
      it "通知はされない" do
        issue_release.save
        sleep 0.1
        expect{
          issue_release.save
        }.to change{Notification.count}.by(0)
      end
    end

    context "ユーザーが限定イシューを投稿した場合" do
      it "担当メンターに通知が作成され、その他には通知されない" do
        expect{
          issue_limited.save
          expect(mentor.notifications.count).to eq 1
          expect(other_mentor.notifications.count).to eq 0
          expect(user.notifications.count).to eq 0
          expect(other.notifications.count).to eq 0
        }.to change{Notification.count}.by(1)
      end
    end

    context "ユーザーが下書きイシューを投稿した場合" do
      it "通知されない" do
        expect{
          issue_draft.save
          expect(mentor.notifications.count).to eq 0
          expect(other_mentor.notifications.count).to eq 0
          expect(user.notifications.count).to eq 0
          expect(other.notifications.count).to eq 0
        }.not_to change(Notification, :count)
      end
    end

    context "ユーザーが下書きイシューを公開に変更した場合" do
      let!(:issue_draft_change) { create(:issue_rand, :draft, user: user) }
      it "担当メンターに通知が作成され、その他には通知されない" do
        expect{
          issue_draft_change.update(scope: :release)
          expect(mentor.notifications.count).to eq 1
          expect(other_mentor.notifications.count).to eq 0
          expect(user.notifications.count).to eq 0
          expect(other.notifications.count).to eq 0
        }.to change{Notification.count}.by(1)
      end
    end

    context "ユーザーが公開の未解決イシューを解決に変更した場合" do
      let!(:issue_pending_change) { create(:issue_rand, :release, status: :pending, user: user) }
      it "担当メンターに通知が作成され、その他には通知されない" do
        expect{
          issue_pending_change.update(status: :solving)
          expect(mentor.notifications.count).to eq 2
          expect(other_mentor.notifications.count).to eq 0
          expect(user.notifications.count).to eq 0
          expect(other.notifications.count).to eq 0
        }.to change{Notification.count}.by(1)
      end
    end
  end
end
