require "rails_helper"

# Userモデルは、最初に登録した非ゲストユーザーを管理者兼メンターにします。
# ご注意ください。
RSpec.describe "ransackの許可リスト", type: :model do
  let!(:first_user) { create(:admin) }
  let!(:alice) { create(:user, :seq, name: "alice", code: "300001") }
  let!(:bob) { create(:user, :seq, name: "bob", code: "300002", mentor: true) }
  let!(:issue_alice) { create(:issue, title: "alice-title", description: "alice-detail", user: alice, tag_list: "tag_a") }
  let!(:issue_bob) { create(:issue, title: "bob-title", description: "bob-detail", user: bob, status: :solving, scope: :limited, tag_list: "tag_b") }
  let!(:comment) { create(:comment, content: "comment-body", user: alice, issue: issue_bob) }

  def issues_by(query)
    Issue.ransack(query).result(distinct: true)
  end

  def users_by(query)
    User.ransack(query).result(distinct: true)
  end

  describe "許可されていない条件" do
    context "Userの属性の場合" do
      it "条件が無視され全件のままになる" do
        [
          {encrypted_password_start: "nomatch"},
          {email_cont: "nomatch"},
          {admin_eq: false}
        ].each do |query|
          expect(users_by(query)).to match_array User.all
        end
      end
    end

    context "Issueの関連経由の場合" do
      it "条件が無視され全件のままになる" do
        [
          {user_encrypted_password_start: "nomatch"},
          {user_email_cont: "nomatch"},
          {comments_user_email_cont: "nomatch"}
        ].each do |query|
          expect(issues_by(query)).to match_array Issue.all
        end
      end
    end

    context "許可されていない属性でソートする場合" do
      it "ソートが無視される" do
        expect(Issue.ransack(s: "user_email asc").result.order_values).to be_empty
        expect(User.ransack(s: "email asc").result.order_values).to be_empty
      end
    end
  end

  describe "許可された条件" do
    context "Userの検索" do
      it "name_or_code_cont で絞り込める" do
        expect(users_by(name_or_code_cont: "alice")).to match_array [alice]
        expect(users_by(name_or_code_cont: "300002")).to match_array [bob]
      end

      it "mentor_eq で絞り込める" do
        expect(users_by(mentor_eq: true)).to match_array [first_user, bob]
        expect(users_by(mentor_eq: false)).to match_array [alice]
      end

      it "entered_at_eq で絞り込める" do
        expect(users_by(entered_at_eq: alice.entered_at)).to include alice
        expect(users_by(entered_at_eq: first_user.entered_at)).to match_array [first_user]
      end

      it "name でソートできる" do
        expect(User.ransack(s: "name asc").result.to_a).to eq [first_user, alice, bob]
        expect(User.ransack(s: "name desc").result.to_a).to eq [bob, alice, first_user]
      end
    end

    context "Issueの検索" do
      let(:key) { :title_or__description_body_or_comments__content_body_cont }

      it "タイトルで絞り込める" do
        expect(issues_by(key => "alice-title")).to match_array [issue_alice]
      end

      it "詳細で絞り込める" do
        expect(issues_by(key => "bob-detail")).to match_array [issue_bob]
      end

      it "コメントで絞り込める" do
        expect(issues_by(key => "comment-body")).to match_array [issue_bob]
      end

      it "user_id_eq で絞り込める" do
        expect(issues_by(user_id_eq: alice.id)).to match_array [issue_alice]
      end

      it "status_eq で絞り込める" do
        expect(issues_by(status_eq: Issue.statuses[:solving])).to match_array [issue_bob]
      end

      it "scope_eq で絞り込める" do
        expect(issues_by(scope_eq: Issue.scopes[:limited])).to match_array [issue_bob]
      end

      it "tags_name_eq で絞り込める" do
        expect(issues_by(tags_name_eq: "tag_a")).to match_array [issue_alice]
      end

      it "著者名でソートできる" do
        expect(Issue.ransack(s: "user_name asc").result.to_a).to eq [issue_alice, issue_bob]
        expect(Issue.ransack(s: "user_name desc").result.to_a).to eq [issue_bob, issue_alice]
      end

      it "タイトルでソートできる" do
        expect(Issue.ransack(s: "title asc").result.to_a).to eq [issue_alice, issue_bob]
        expect(Issue.ransack(s: "title desc").result.to_a).to eq [issue_bob, issue_alice]
      end
    end
  end
end
