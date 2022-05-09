require 'rails_helper'
RSpec.describe :pagination, type: :system do
  let!(:mentor) { create(:mentor) }
  describe "部員一覧" do
    before do
      29.times { FactoryBot.create(:user, :seq) }
      sign_in mentor
      visit users_path
    end

    context "30人のユーザーがいる場合" do
      it "最初のページに20人表示される" do
        expect(page).to have_content "990", count: 19
        expect(page).to have_content "200001", count: 1
      end

      it "次ページに10人表示される" do
        click_on I18n.t("views.pagination.next")
        sleep 0.2
        expect(page).to have_content "990", count: 10
      end
    end
  end

  describe "イシュー一覧" do
    before do
      30.times { FactoryBot.create(:issue, user: mentor) }
      sign_in mentor
      visit issues_path
    end

    context "30件のイシューがある場合" do
      it "スクロールしないと20件表示される" do
        expect(page).to have_content Issue.last.title, count: 20
      end

      it "スクロールすると30件表示される" do
        execute_script("window.scrollBy(0, 10000)")
        sleep 0.3
        expect(page).to have_content Issue.last.title, count: 30
      end
    end
  end
end
