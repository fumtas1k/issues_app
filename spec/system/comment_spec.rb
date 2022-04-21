require 'rails_helper'
RSpec.describe :comment, type: :system do
  let!(:mentor) { create(:mentor) }
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user, :seq) }
  let!(:issue) { create(:issue, user: user) }

  describe "コメント投稿機能" do
    before do
      sign_in user
      visit issue_path(issue)
      fill_in_rich_text_area "comment_content", with: comment_params[:content]
      file_attach
      click_on I18n.t("helpers.submit.create")
      sleep 0.1
    end

    context "必要事項を入力した場合" do
      let(:comment_params) { attributes_for(:comment) }
      let(:file_attach) {
        page.attach_file("#{Rails.root}/app/assets/images/sample.jpg") do
          page.find(".trix-button--icon-attach").click
        end
      }
      it "保存されて、コメントが表示される" do
        expect(Comment.last.content.to_plain_text).to eq "[sample.jpg]#{comment_params[:content]}"
        expect(page).to have_content comment_params[:content]
      end
    end

    context "コンテンツを空にして投稿した場合" do
      let(:comment_params) { attributes_for(:comment, content: "") }
      let(:file_attach) {""}
      it "エラーメッセージが表示され投稿されない" do
        expect(Comment.count).to eq 0
        expect(page).to have_content I18n.t("errors.messages.blank")
      end
    end
    context "詳細の添付がいるが5MBを超えた場合" do
      let(:comment_params) { attributes_for(:comment) }
      let(:file_attach) {
        page.attach_file("#{Rails.root}/spec/fixtures/images/nature6.5MB.jpg") do
          page.find(".trix-button--icon-attach").click
        end
      }
      it "エラーメッセージが表示され投稿されない" do
        sleep 0.3
        expect(Comment.count).to eq 0
        expect(page).to have_css ".alert-danger"
        expect(page).to have_content "6513431"
      end
    end
  end

  describe "編集・更新機能" do
    let!(:comment) {create(:comment, user: user, issue: issue)}

    context "投稿したユーザーが編集ボタンを押した場合" do
      before do
        sign_in user
        visit issue_path(issue)
        find(".comment-edit-btn").click
      end
      let!(:content) { "change change change" }
      it "編集フォームが出現し編集できる" do
        within "#comment-form-#{comment.id}" do
          fill_in_rich_text_area "comment_content", with: content
          click_on I18n.t("helpers.submit.update")
        end
        sleep 0.1
        expect(Comment.last.content.to_plain_text).to eq content
        expect(page).to have_content content
      end
    end

    context "投稿したユーザーとは別のユーザーが編集ボタンを押そうとした場合" do
      it "ボタンは表示されておらず押せない" do
        sign_in other_user
        visit issue_path(issue)
        expect(page).not_to have_css ".comment-edit-btn"
      end
    end
  end

  describe "削除機能" do
    let!(:comment) {create(:comment, user: user, issue: issue)}

    context "投稿したユーザーが削除ボタンを押した場合" do
      it "削除できる" do
        sign_in user
        visit issue_path(issue)
        expect{
          page.accept_confirm {
            find(".comment-delete-btn").click
          }
          expect(page).not_to have_content comment.content.to_plain_text
        }.to change {Comment.count}.by(-1)
      end
    end

    context "投稿したユーザーとは別のユーザーが削除ボタンを押そうとした場合" do
      it "ボタンが見当たらず削除できない" do
        sign_in other_user
        visit issue_path(issue)
        expect(page).not_to have_css ".comment-delete-btn"
      end
    end
  end
end
