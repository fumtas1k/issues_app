require 'rails_helper'

# モデルにて、最初に登録したユーザーを管理者兼メンター権限とする設定にしています。
# ご注意ください。
RSpec.describe :issue, type: :system do
  describe "検索機能" do
    let!(:mentor) { create(:mentor) }
    let!(:fukuzawa) { create(:user, :seq, name: "fukuzawa") }
    let!(:higuchi) { create(:user, :seq, name: "ichiyo") }
    let!(:noguchi) { create(:user, :seq, name: "hideyo") }
    let!(:grouping) { create(:grouping, group: mentor.group, user: noguchi)}
    let!(:common) { "common" }
    let!(:issue_fukuzawa_release_pending) { create(:issue, title: "福沢#{common}", description: "諭吉だよ", user: fukuzawa) }
    let!(:issue_higuchi_release_solving) { create(:issue, title: "樋口#{common}", description: "一葉どす", status: :solving, tag_list: "money", user: higuchi) }
    let!(:issue_noguchi_limited_pending) { create(:issue, title: "野口#{common}", description: "英世です", status: :pending, scope: :limited, user: noguchi) }
    let!(:comment_fukuzawa_to_higuchi) { create(:comment, content: "次は津田梅子", user: fukuzawa, issue: issue_higuchi_release_solving) }
    before do
      sign_in mentor
    end

    context "存在するイシュータイトルで検索する場合" do
      let(:search_attr) { {issue_or_comment: issue_fukuzawa_release_pending.title, user_name: "", status: "", scope: "", tag: ""} }
      before do
        visit issues_path
        fill_in "q_title_or__description_body_or_comments__content_body_cont", with: search_attr[:issue_or_comment]
        find(".btn-search").click
      end
      it "該当イシューのみ表示される" do
        expect(page).to have_content search_attr[:issue_or_comment], count: 1
        expect(page).to have_content common, count: 1
      end
    end
    context "存在するイシュー詳細で検索する場合" do
      let(:search_attr) { {issue_or_comment: issue_fukuzawa_release_pending.description.to_plain_text, user_name: "", status: "", scope: "", tag: ""} }
      before do
        visit issues_path
        fill_in "q_title_or__description_body_or_comments__content_body_cont", with: search_attr[:issue_or_comment]
        find(".btn-search").click
      end
      it "その詳細を含むイシューのみ表示される" do
        expect(page).to have_content issue_fukuzawa_release_pending.title
        expect(page).to have_content common, count: 1
      end
    end

    context "存在するコメントで検索する場合" do
      let(:search_attr) { {issue_or_comment: comment_fukuzawa_to_higuchi.content.to_plain_text, user_name: "", status: "", scope: "", tag: ""} }
      before do
        visit issues_path
        fill_in "q_title_or__description_body_or_comments__content_body_cont", with: search_attr[:issue_or_comment]
        find(".btn-search").click
      end
      it "そのコメントがされたイシューのみ表示される" do
        expect(page).to have_content issue_higuchi_release_solving.title
        expect(page).to have_content common, count: 1
      end
    end

    context "存在しないイシュー、コメントで検索する場合" do
      let(:search_attr) { {issue_or_comment: "not exist", user_name: "", status: "", scope: "", tag: ""} }
      before do
        visit issues_path
        fill_in "q_title_or__description_body_or_comments__content_body_cont", with: search_attr[:issue_or_comment]
        find(".btn-search").click
      end
      it "イシューは表示されず、該当するデータがない旨が表示される" do
        expect(page).not_to have_content common
        expect(page).to have_content I18n.t("views.blank")
      end
    end

    context "存在する著者で検索する場合" do
      let(:search_attr) { {issue_or_comment: "", user_name: fukuzawa.name, status: "", scope: "", tag: ""} }
      before do
        visit issues_path
        select search_attr[:user_name], from: "q_user_id_eq"
        find(".btn-search").click
      end
      it "著者のイシューのみ表示される" do
        expect(page).to have_content search_attr[:user_name]
        expect(page).to have_content common, count: 1
      end
    end

    context "状態を未解決で検索する場合" do
      let(:search_attr) { {issue_or_comment: "", user_name: "", status: :pending, scope: "", tag: ""} }
      before do
        visit issues_path
        select Issue.human_enum_status(search_attr[:status]), from: "q_status_eq"
        find(".btn-search").click
      end
      it "未解決イシューのみ表示される" do
        expect(page).to have_content Issue.human_enum_status(search_attr[:status])
        expect(page).to have_content common, count: 2
      end
    end

    context "公開を限定で検索する場合" do
      # group外のユーザーの限定イシュー：限定イシューは合計2つだが、これは表示されないはず
      let!(:issue_fukuzawa_limited_pending) { create(:issue, title: "福沢#{common}", description: "諭吉だよ", user: fukuzawa, scope: :limited) }
      let(:search_attr) { {issue_or_comment: "", user_name: "", status: "", scope: :limited, tag: ""} }
      before do
        visit issues_path
        select Issue.human_enum_scope(search_attr[:scope]), from: "q_scope_eq"
        find(".btn-search").click
      end
      it "限定イシューのみ表示される" do
        expect(page).to have_content Issue.human_enum_scope(search_attr[:scope])
        expect(page).to have_content common, count: 1
      end
    end

    context "タグで検索する場合" do
      let(:search_attr) { {issue_or_comment: "", user_name: "", status: "", scope: "", tag: issue_higuchi_release_solving[:tag_list][0]} }
      before do
        visit issues_path
        select search_attr[:tag], from: "q_tags_name_eq"
        find(".btn-search").click
      end
      it "検索タグのイシューのみ表示される" do
        expect(page).to have_content search_attr[:tag]
        expect(page).to have_content common, count: 1
      end
    end
  end

  describe "ソート機能" do
    # いいね、ストック数でのソート機能は、0が最小とならない。おそらく、存在しないため、0となっていないのだろう
    # 従って、ソート機能自体狂っているので、これらのテストはペンディングとする
    let!(:mentor) { create(:mentor) }
    let!(:alice) { create(:user, :seq, name: "alice") }
    let!(:bob) { create(:user, :seq, name: "bob") }
    let!(:charlie) { create(:user, :seq, name: "charlie") }
    let!(:grouping) { create(:grouping, group: mentor.group, user: charlie)}
    let!(:common) { "common" }
    let!(:issue_alice_2nd_2020) { create(:issue, title: "2nd#{common}", description: "アリスだよ", user: alice, created_at: "2020-04-01") }
    let!(:issue_bob_1st_2015) { create(:issue, title: "1st#{common}", description: "ボブどす", user: bob, created_at: "2015-04-01") }
    let!(:issue_charlie_3rd_2010) { create(:issue, title: "3rd#{common}", description: "チャーリーです", user: charlie, created_at: "2010-04-01") }
    before do
      sign_in mentor
    end

    context "タイトルでソートした場合" do
      before do
        visit issues_path
        find("#sort-issue-title").click
        sleep 0.1
      end
      it "タイトルの昇順でソートされる" do
        expect(all(".issue-container")[0]).to have_content issue_bob_1st_2015.title
        expect(all(".issue-container")[1]).to have_content issue_alice_2nd_2020.title
        expect(all(".issue-container")[2]).to have_content issue_charlie_3rd_2010.title
      end
    end

    context "著者名でソートした場合" do
      before do
        visit issues_path
        find("#sort-issue-user").click
        sleep 0.1
      end
      it "著者名の昇順でソートされる" do
        expect(all(".issue-container")[0]).to have_content issue_alice_2nd_2020.user.name
        expect(all(".issue-container")[1]).to have_content issue_bob_1st_2015.user.name
        expect(all(".issue-container")[2]).to have_content issue_charlie_3rd_2010.user.name
      end
    end

    context "作成日でソートした場合" do
      before do
        visit issues_path
        find("#sort-issue-created_at").click
        sleep 0.1
      end
      it "作成日の昇順でソートされる" do
        expect(all(".issue-container")[0]).to have_content issue_charlie_3rd_2010.user.name
        expect(all(".issue-container")[1]).to have_content issue_bob_1st_2015.user.name
        expect(all(".issue-container")[2]).to have_content issue_alice_2nd_2020.user.name
      end
    end

    context "いいね数でソートした場合" do
      pending "一番大きい数が0となってしまう問題発生中"
    end

    context "ストック数でソートした場合" do
      pending "一番大きい数が0となってしまう問題発生中"
    end
  end
end

RSpec.describe :user, type: :system do
  describe "検索機能" do
    let(:common) { "common" }
    let!(:alice_2_2020_mentor) { create(:user, :seq, name: "alice#{common}", code: "100002", entered_at: "2020-04-01", mentor: true) }
    let!(:bob_1_2015) { create(:user, :seq, name: "bob#{common}", code: "100001", entered_at: "2015-04-01") }
    let!(:charlie_3_2010) { create(:user, :seq, name: "charlie#{common}", code: "100003", entered_at: "2010-04-01") }
    before do
      sign_in alice_2_2020_mentor
    end

    context "名前で検索した場合" do
      let(:search_attr) { {name: alice_2_2020_mentor.name, code: "", entered_at: "", role: "" } }
      before do
        visit users_path
        fill_in "q_name_or_code_cont", with: search_attr[:name]
        click_on I18n.t("views.btn.search")
        sleep 0.1
      end
      it "検索の名前のみ表示される" do
        expect(page).to have_content alice_2_2020_mentor.name
        expect(page).to have_content common, count: 2
      end
    end

    context "職員コードで検索した場合" do
      let(:search_attr) { {name: "", code: bob_1_2015.code, entered_at: "", role: "" } }
      before do
        visit users_path
        fill_in "q_name_or_code_cont", with: search_attr[:code]
        click_on I18n.t("views.btn.search")
        sleep 0.1
      end
      it "検索の職員コードのみ表示される" do
        expect(page).to have_content bob_1_2015.name
        expect(page).to have_content common, count: 2
      end
    end

    context "役割で検索した場合" do
      let(:search_attr) { {name: "", code: "", entered_at: "", role: :mentor} }
      before do
        visit users_path
        select User.human_attribute_name(search_attr[:role]), from: "q_mentor_eq"
        click_on I18n.t("views.btn.search")
        sleep 0.1
      end
      it "検索の役割のみ表示される" do
        expect(page).to have_content alice_2_2020_mentor.name
        expect(page).to have_content common, count: 2
      end
    end

    context "入職日で検索した場合" do
      let(:search_attr) { {name: "", code: "", entered_at: charlie_3_2010.entered_at, mentor: "" } }
      before do
        visit users_path
        fill_in "q_entered_at_eq", with: search_attr[:entered_at]
        click_on I18n.t("views.btn.search")
        sleep 0.1
      end
      it "検索の入職日のみ表示される" do
        expect(page).to have_content charlie_3_2010.name
        expect(page).to have_content common, count: 2
      end
    end
  end

  describe "ソート機能" do
    let!(:alice_2_2020_mentor) { create(:user, :seq, name: "alice", code: "100002", entered_at: "2020-04-01", mentor: true) }
    let!(:bob_1_2015) { create(:user, :seq, name: "bob", code: "100001", entered_at: "2015-04-01") }
    let!(:charlie_3_2010) { create(:user, :seq, name: "charlie", code: "100003", entered_at: "2010-04-01") }
    before do
      sign_in alice_2_2020_mentor
    end

    context "名前でソートした場合" do
      before do
        visit users_path
        find("#sort-user-name").click
        sleep 0.1
      end
      it "名前の昇順でソートされる" do
        expect(all("tbody tr")[0]).to have_content alice_2_2020_mentor.name
        expect(all("tbody tr")[1]).to have_content bob_1_2015.name
        expect(all("tbody tr")[2]).to have_content charlie_3_2010.name
      end
    end

    context "職員コードでソートした場合" do
      before do
        visit users_path
        find("#sort-user-code").click
        sleep 0.1
      end
      it "職員コードの昇順でソートされる" do
        expect(all("tbody tr")[0]).to have_content bob_1_2015.code
        expect(all("tbody tr")[1]).to have_content alice_2_2020_mentor.code
        expect(all("tbody tr")[2]).to have_content charlie_3_2010.code
      end
    end

    context "役割でソートした場合" do
      before do
        visit users_path
        find("#sort-user-role").click
        sleep 0.1
      end
      it "メンターが最下部にくる" do
        expect(all("tbody tr").last).to have_content alice_2_2020_mentor.name
      end
    end

    context "入職日でソートした場合" do
      before do
        visit users_path
        find("#sort-user-entered_at").click
        sleep 0.1
      end
      it "入職日の昇順でソートされる" do
        expect(all("tbody tr")[0]).to have_content charlie_3_2010.code
        expect(all("tbody tr")[1]).to have_content bob_1_2015.code
        expect(all("tbody tr")[2]).to have_content alice_2_2020_mentor.code
      end
    end
  end
end
