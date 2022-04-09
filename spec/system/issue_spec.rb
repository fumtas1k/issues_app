require 'rails_helper'
RSpec.describe :issue, type: :system do
  let!(:mentor) { create(:mentor) }
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user, :seq) }
  let!(:grouping) { create(:grouping, user: user, group: mentor.group) }
  let!(:other_mentor) { create(:user, :seq, name: "other_mentor", mentor: true) }

  describe "投稿機能" do
    before do
      sign_in user
      visit new_issue_path
      fill_in "issue_title", with: issue_params[:title]
      select Issue.human_enum_status(issue_params[:status]), from: Issue.human_attribute_name(:status)
      select Issue.human_enum_scope(issue_params[:scope]), from: Issue.human_attribute_name(:scope)
      fill_in_rich_text_area "issue_description", with: issue_params[:description]
      file_attach
      click_on I18n.t("helpers.submit.create")
    end

    context "必要事項を入力した場合" do
      let(:issue_params) { attributes_for(:issue) }
      let(:file_attach) {
        page.attach_file("#{Rails.root}/app/assets/images/sample.jpg") do
          page.find(".trix-button--icon-attach").click
        end
      }
      it "保存されて、詳細ページが表示される" do
        expect(Issue.last.title).to eq issue_params[:title]
        expect(page).to have_content issue_params[:title]
      end
    end

    context "必要事項を入力し、デフォルト以外のstatusを選択した場合" do
      let(:issue_params) { attributes_for(:issue, :solving) }
      let(:file_attach) { "" }
      it "詳細ページに飛び、選択したstatusが表示される" do
        expect(Issue.last.title).to eq issue_params[:title]
        expect(page).to have_content issue_params[:title]
        expect(page).to have_content Issue.human_enum_status(issue_params[:status])
      end
    end

    context "必要事項を入力し、デフォルト以外のscopeを選択した場合" do
      let(:issue_params) { attributes_for(:issue, :limited) }
      let(:file_attach) { "" }
      it "詳細ページに飛び、選択したscopeが表示される" do
        expect(Issue.last.title).to eq issue_params[:title]
        expect(page).to have_content issue_params[:title]
        expect(page).to have_content Issue.human_enum_scope(issue_params[:scope])
      end
    end

    context "タイトルを空にした場合" do
      let(:issue_params) { attributes_for(:issue, title: "") }
      let(:file_attach) {
        page.attach_file("#{Rails.root}/app/assets/images/sample.jpg") do
          page.find(".trix-button--icon-attach").click
        end
      }
      it "投稿画面に戻りエラーメッセージが表示される" do
        expect(Issue.count).to eq 0
        expect(page).to have_content I18n.t("errors.messages.empty")
        expect(page).to have_content I18n.t("views.issues.new.title")
      end
    end

    context "詳細を空にした場合" do
      let(:issue_params) { attributes_for(:issue, description: "") }
      let(:file_attach) { "" }
      it "投稿画面に戻りエラーメッセージが表示される" do
        expect(Issue.count).to eq 0
        expect(page).to have_content I18n.t("errors.messages.empty")
        expect(page).to have_content I18n.t("views.issues.new.title")
      end
    end
  end

  describe "一覧表示機能" do
    # 公開、限定、下書きの3パターンを作成
    let!(:release_issue) { create(:issue, user: user) }
    let!(:limited_issue) { create(:issue, :limited, user: user) }
    let!(:draft_issue) { create(:issue, :draft, user: user) }

    context "3つのissueを投稿したユーザーが一覧表示にアクセスした場合" do
      it "3つとも表示される" do
        sign_in user
        visit issues_path
        expect(page).to have_content Issue.human_enum_scope(:release)
        expect(page).to have_content Issue.human_enum_scope(:limited)
        expect(page).to have_content Issue.human_enum_scope(:draft)
      end
    end

    context "3つの投稿とは別のたユーザーが一覧表示にアクセスした場合" do
      it "releaseのみ表示される" do
        sign_in other_user
        visit issues_path
        expect(page).to have_content Issue.human_enum_scope(:release)
        expect(page).not_to have_content Issue.human_enum_scope(:limited)
        expect(page).not_to have_content Issue.human_enum_scope(:draft)
      end
    end

    context "投稿したユーザーの担当メンターが一覧表示にアクセスした場合" do
      it "draft以外2つのイシューが表示される" do
        sign_in mentor
        visit issues_path
        expect(page).to have_content Issue.human_enum_scope(:release)
        expect(page).to have_content Issue.human_enum_scope(:limited)
        expect(page).not_to have_content Issue.human_enum_scope(:draft)
      end
    end

    context "投稿したユーザーの担当ではないメンターが一覧表示にアクセスした場合" do
      it "releaseのみ表示される" do
        sign_in other_mentor
        visit issues_path
        expect(page).to have_content Issue.human_enum_scope(:release)
        expect(page).not_to have_content Issue.human_enum_scope(:limited)
        expect(page).not_to have_content Issue.human_enum_scope(:draft)
      end
    end
  end

  describe "詳細表示機能(アクセス制御含む)" do
    # 公開、限定、下書きの3パターンを作成
    let!(:release_issue) { create(:issue, user: user) }
    let!(:limited_issue) { create(:issue, :limited, user: user) }
    let!(:draft_issue) { create(:issue, :draft, user: user) }

    context "3つの投稿ユーザーがイシュー詳細にアクセスした場合" do
      before { sign_in user }
      it "3つの詳細ページともアクセス出来る" do
        expect{visit issue_path(release_issue)}.to change {current_path}.to(issue_path(release_issue))
        expect{visit issue_path(limited_issue)}.to change {current_path}.to(issue_path(limited_issue))
        expect{visit issue_path(draft_issue)}.to change {current_path}.to(issue_path(draft_issue))
      end
    end

    context "3つの投稿とは別のたユーザーがイシュー詳細にアクセスした場合" do
      before { sign_in other_user }
      it "releaseのみ詳細ページにアクセスでき、他はイシュー一覧に飛ぶ" do
        expect{visit issue_path(release_issue)}.to change {current_path}.to(issue_path(release_issue))
        expect{visit issue_path(limited_issue)}.to change {current_path}.to(issues_path)
        expect{visit issue_path(draft_issue)}.not_to change {current_path}
      end
    end

    context "投稿したユーザーの担当メンターがイシュー詳細にアクセスした場合" do
      before { sign_in mentor }
      it "release, limitedはアクセスでき、draftはイシュー一覧に飛ぶ" do
        expect{visit issue_path(release_issue)}.to change {current_path}.to(issue_path(release_issue))
        expect{visit issue_path(limited_issue)}.to change {current_path}.to(issue_path(limited_issue))
        expect{visit issue_path(draft_issue)}.to change {current_path}.to(issues_path)
      end
    end

    context "投稿したユーザーの担当ではないメンターがイシュー詳細にアクセスした場合" do
      before { sign_in other_mentor }
      it "releaseのみ詳細ページにアクセスでき、他はイシュー一覧に飛ぶ" do
        expect{visit issue_path(release_issue)}.to change {current_path}.to(issue_path(release_issue))
        expect{visit issue_path(limited_issue)}.to change {current_path}.to(issues_path)
        expect{visit issue_path(draft_issue)}.not_to change {current_path}
      end
    end
  end

  describe "更新機能" do
    let!(:release_issue) { create(:issue, user: user) }

    context "イシューを全て書き換えたとき" do
      before do
        sign_in user
        visit edit_issue_path(release_issue)
        fill_in "issue_title", with: issue_params[:title]
        select Issue.human_enum_status(issue_params[:status]), from: Issue.human_attribute_name(:status)
        select Issue.human_enum_scope(issue_params[:scope]), from: Issue.human_attribute_name(:scope)
        fill_in_rich_text_area "issue_description", with: issue_params[:description]
        page.attach_file("#{Rails.root}/app/assets/images/sample.jpg") do
          page.find(".trix-button--icon-attach").click
        end
        click_on I18n.t("helpers.submit.update")
      end
      let(:issue_params) { attributes_for(:issue_rand, scope: Issue.human_enum_scope(:limited), status: Issue.human_enum_status(:solving)) }
      it "データが更新され、詳細ページが表示される" do
        expect(page).to have_content issue_params[:title]
        expect(page).to have_content issue_params[:description]
        expect(page).to have_content Issue.human_enum_scope(issue_params[:scope])
        expect(page).to have_content Issue.human_enum_status(issue_params[:status])
      end
    end

    context "他人のイシューを編集しようとした場合" do
      it "イシュー一覧にリダイレクトしフラッシュが表示される" do
        sign_in other_user
        visit edit_issue_path(release_issue)
        expect(current_path).to eq issues_path
        expect(page).to have_content I18n.t("views.issues.flash.author_required")
      end
    end
  end

  describe "削除機能" do
    let!(:release_issue) { create(:issue, user: user) }

    context "自分の投稿の削除ボタンを押した場合" do
      it "削除できる" do
        sign_in user
        visit issue_path(release_issue)
        expect{
          page.accept_confirm {
            click_link I18n.t("views.btn.delete"), href: issue_path(release_issue)
          }
          find ".alert", text: I18n.t("views.issues.flash.destroy", title: release_issue.title)
        }.to change {Issue.count}.by(-1)
      end
    end

    # 削除ボタンの表示制御機能をつけたらこのテストも消す
    context "他人の投稿の削除ボタンを押した場合" do
      it "削除できない" do
        sign_in other_user
        visit issue_path(release_issue)
        expect{
          page.accept_confirm {
            click_link I18n.t("views.btn.delete"), href: issue_path(release_issue)
          }
          find ".alert", text: I18n.t("views.issues.flash.author_required")
        }.not_to change {Issue.count}
      end
    end
  end
end
