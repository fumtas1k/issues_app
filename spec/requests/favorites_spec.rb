require 'rails_helper'
RSpec.describe "Favorites", type: :request do
  let!(:mentor) { create(:mentor) } # 最初の登録ユーザーがメンターになってしまうために用意
  let!(:group) { ensure_group(mentor) }
  let!(:author) { create(:user) }
  let!(:other_user) { create(:user, :seq) }
  let!(:other_mentor) { create(:user, :seq, mentor: true) }
  let!(:other_group) { ensure_group(other_mentor) }
  let!(:grouping) { create(:grouping, user: author, group: group) }
  let!(:release_issue) { create(:issue, user: author) }
  let!(:limited_issue) { create(:issue, :limited, user: author) }
  let!(:draft_issue) { create(:issue, :draft, user: author) }

  describe "POST /issues/:issue_id/favorites" do
    context "未ログインの場合" do
      it "ログイン画面にリダイレクトされ、作成されない" do
        expect {
          post issue_favorites_path(release_issue)
        }.not_to change(Favorite, :count)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "公開のイシューの場合" do
      it "他人は作成できる" do
        sign_in other_user
        expect {
          post issue_favorites_path(release_issue)
        }.to change { other_user.favorites.count }.by(1)
        expect(response).to redirect_to(issues_path)
      end
    end

    context "他人の下書きのイシューの場合" do
      it "イシュー一覧にリダイレクトされ、作成されない" do
        sign_in other_user
        expect {
          post issue_favorites_path(draft_issue)
        }.not_to change(Favorite, :count)
        expect(response).to redirect_to(issues_path)
        expect(flash[:danger]).to eq I18n.t("views.issues.flash.inaccessible")
      end

      it "メンターでも作成されない" do
        sign_in mentor
        expect {
          post issue_favorites_path(draft_issue)
        }.not_to change(Favorite, :count)
        expect(response).to redirect_to(issues_path)
      end
    end

    context "限定のイシューの場合" do
      it "メンターでない他人は作成できない" do
        sign_in other_user
        expect {
          post issue_favorites_path(limited_issue)
        }.not_to change(Favorite, :count)
        expect(response).to redirect_to(issues_path)
      end

      it "グループが違うメンターは作成できない" do
        sign_in other_mentor
        expect {
          post issue_favorites_path(limited_issue)
        }.not_to change(Favorite, :count)
        expect(response).to redirect_to(issues_path)
      end

      it "グループのメンターは作成できる" do
        sign_in mentor
        expect {
          post issue_favorites_path(limited_issue)
        }.to change { mentor.favorites.count }.by(1)
      end
    end
  end

  describe "DELETE /issues/:issue_id/favorites/:id" do
    context "未ログインの場合" do
      it "ログイン画面にリダイレクトされ、削除されない" do
        record = create(:favorite, user: other_user, issue: release_issue)
        expect {
          delete issue_favorite_path(release_issue, record)
        }.not_to change(Favorite, :count)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "公開のイシューの場合" do
      it "自分の分を削除できる" do
        record = create(:favorite, user: other_user, issue: release_issue)
        sign_in other_user
        expect {
          delete issue_favorite_path(release_issue, record)
        }.to change(Favorite, :count).by(-1)
      end
    end

    context "閲覧できない下書きのイシューの場合" do
      it "削除されず、イシュー一覧にリダイレクトされる" do
        record = create(:favorite, user: other_user, issue: draft_issue)
        sign_in other_user
        expect {
          delete issue_favorite_path(draft_issue, record)
        }.not_to change(Favorite, :count)
        expect(response).to redirect_to(issues_path)
      end
    end

    context "閲覧できない限定のイシューの場合" do
      it "削除されず、イシュー一覧にリダイレクトされる" do
        record = create(:favorite, user: other_user, issue: limited_issue)
        sign_in other_user
        expect {
          delete issue_favorite_path(limited_issue, record)
        }.not_to change(Favorite, :count)
        expect(response).to redirect_to(issues_path)
      end
    end
  end
end
