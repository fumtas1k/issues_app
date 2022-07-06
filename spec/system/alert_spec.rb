require 'rails_helper'
RSpec.describe :alert, type: :system do
  describe "alertの削除機能" do
    before do
      visit root_path
      click_on I18n.t("devise.sessions.new.guest_sign_in")
    end

    context "ゲストログインした後、何もしない場合" do
      it "0.5s後もフラッシュ(alert)は消えない" do
        sleep 0.5
        expect(page).to have_css ".alert"
      end
    end

    context "ゲストログインした後、フラッシュ(alert)のcloseボタンを押した場合" do
      it "フラッシュ(alert)が0.5s後に消える" do
        expect(page).to have_css ".alert"
        find(".alert-close").click
        sleep 0.5
        expect(page).not_to have_css ".alert"
      end
    end
  end
end
