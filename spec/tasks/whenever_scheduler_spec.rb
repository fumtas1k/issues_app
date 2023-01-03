require 'rails_helper'
require_relative '../support/rake_helper'

RSpec.describe :whenever_scheduler, type: :task do
  describe "delete_notification" do
    let!(:user) { create(:user) }
    let!(:other) { create(:user, :seq) }
    let!(:issue) { create(:issue, user_id: user.id) }
    let!(:favorite) { create(:favorite, user_id: other.id, issue_id: issue.id) }
    let!(:stock) { create(:stock, user_id: other.id, issue_id: issue.id) }
    let(:task) { Rake.application["whenever_scheduler:delete_notification"] }

    context "29日以上前の通知と28日以内の通知がある場合" do
      it "29日以上前の通知のみ削除される" do
        favorite.notification.update(created_at: 29.days.ago)
        expect{
          task.invoke
          expect(Notification.first.id).to eq stock.notification.id
        }.to change { Notification.count }.from(2).to(1)
      end
    end
  end

  describe "purge_unattached" do
    let!(:user) { create(:user) }
    let(:task) { Rake.application["whenever_scheduler:purge_unattached"]}
    pending "アタッチされていないファイルの作成方法がわからない"
  end
end
