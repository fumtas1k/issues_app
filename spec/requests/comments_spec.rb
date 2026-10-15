require 'rails_helper'
RSpec.describe "Comments", type: :request do
  let!(:mentor) { create(:mentor) } # 最初の登録ユーザーがメンターになってしまうために用意
  let!(:group) { ensure_group(mentor) }
  let!(:author) { create(:user) }
  let!(:other_user) { create(:user, :seq) }
  let!(:other_mentor) { create(:user, :seq, mentor: true) }
  let!(:other_group) { ensure_group(other_mentor) }
  let!(:grouping) { create(:grouping, user: author, group: group) }
  let(:comment_params) { { comment: { content: "コメントです" } } }

  describe "POST /issues/:issue_id/comments" do
    let!(:release_issue) { create(:issue, user: author) }
    let!(:limited_issue) { create(:issue, :limited, user: author) }
    let!(:draft_issue) { create(:issue, :draft, user: author) }

    context "未ログインの場合" do
      it "ログイン画面にリダイレクトされ、コメントは作成されない" do
        expect {
          post issue_comments_path(release_issue), params: comment_params
        }.not_to change(Comment, :count)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "公開のイシューの場合" do
      it "他人でもコメントできる" do
        sign_in other_user
        expect {
          post issue_comments_path(release_issue), params: comment_params
        }.to change(Comment, :count).by(1)
        expect(response).to redirect_to(issue_path(release_issue))
      end
    end

    context "他人の下書きのイシューの場合" do
      it "イシュー一覧にリダイレクトされ、コメントは作成されない" do
        sign_in other_user
        expect {
          post issue_comments_path(draft_issue), params: comment_params
        }.not_to change(Comment, :count)
        expect(response).to redirect_to(issues_path)
        expect(flash[:danger]).to eq I18n.t("views.issues.flash.inaccessible")
      end

      it "メンターでも作成されない" do
        sign_in mentor
        expect {
          post issue_comments_path(draft_issue), params: comment_params
        }.not_to change(Comment, :count)
        expect(response).to redirect_to(issues_path)
      end
    end

    context "限定のイシューの場合" do
      it "メンターでない他人はコメントできない" do
        sign_in other_user
        expect {
          post issue_comments_path(limited_issue), params: comment_params
        }.not_to change(Comment, :count)
        expect(response).to redirect_to(issues_path)
      end

      it "グループが違うメンターはコメントできない" do
        sign_in other_mentor
        expect {
          post issue_comments_path(limited_issue), params: comment_params
        }.not_to change(Comment, :count)
        expect(response).to redirect_to(issues_path)
      end

      it "グループのメンターはコメントできる" do
        sign_in mentor
        expect {
          post issue_comments_path(limited_issue), params: comment_params
        }.to change(Comment, :count).by(1)
        expect(response).to redirect_to(issue_path(limited_issue))
      end

      it "作成者本人はコメントできる" do
        sign_in author
        expect {
          post issue_comments_path(limited_issue), params: comment_params
        }.to change(Comment, :count).by(1)
      end
    end
  end

  describe "PATCH/DELETE /issues/:issue_id/comments/:id" do
    let!(:issue) { create(:issue, user: author) }
    let!(:other_issue) { create(:issue, user: author) }
    let!(:comment) { create(:comment, user: other_user, issue: issue, content: "元のコメント") }
    let(:update_params) { { comment: { content: "更新後" } } }

    context "未ログインの場合" do
      it "更新も削除もできない" do
        patch issue_comment_path(issue, comment), params: update_params, xhr: true
        expect(response).not_to have_http_status(:ok)
        expect {
          delete issue_comment_path(issue, comment), xhr: true
        }.not_to change(Comment, :count)
        expect(comment.reload.content.to_plain_text).to eq "元のコメント"
      end
    end

    context "コメントの作成者の場合" do
      before { sign_in other_user }

      it "更新できる" do
        patch issue_comment_path(issue, comment), params: update_params, xhr: true
        expect(response).to have_http_status(:ok)
        expect(comment.reload.content.to_plain_text).to eq "更新後"
      end

      it "削除できる" do
        expect {
          delete issue_comment_path(issue, comment), xhr: true
        }.to change(Comment, :count).by(-1)
      end

      it "issue_idを送っても付け替えられない" do
        patch issue_comment_path(issue, comment),
              params: { comment: { content: "更新後", issue_id: other_issue.id } }, xhr: true
        expect(comment.reload.issue_id).to eq issue.id
      end
    end

    context "コメントの作成者でない場合" do
      before { sign_in author }

      it "更新できない" do
        patch issue_comment_path(issue, comment), params: update_params, xhr: true
        expect(response).to redirect_to(issues_path)
        expect(comment.reload.content.to_plain_text).to eq "元のコメント"
      end

      it "削除できない" do
        expect {
          delete issue_comment_path(issue, comment), xhr: true
        }.not_to change(Comment, :count)
        expect(response).to redirect_to(issues_path)
      end
    end

    context "別のイシューのコメントIDを指定した場合" do
      before { sign_in other_user }

      it "更新できない" do
        expect_not_found {
          patch issue_comment_path(other_issue, comment), params: update_params, xhr: true
        }
        expect(comment.reload.content.to_plain_text).to eq "元のコメント"
      end

      it "削除できない" do
        expect {
          expect_not_found {
            delete issue_comment_path(other_issue, comment), xhr: true
          }
        }.not_to change(Comment, :count)
      end
    end

    context "コメント後に下書きに変更され、閲覧できなくなったイシューの場合" do
      before do
        issue.update!(scope: :draft)
        sign_in other_user
      end

      it "作成者でも更新できない" do
        patch issue_comment_path(issue, comment), params: update_params, xhr: true
        expect(response).to redirect_to(issues_path)
        expect(comment.reload.content.to_plain_text).to eq "元のコメント"
      end

      it "作成者でも削除できない" do
        expect {
          delete issue_comment_path(issue, comment), xhr: true
        }.not_to change(Comment, :count)
        expect(response).to redirect_to(issues_path)
      end
    end
  end
end
