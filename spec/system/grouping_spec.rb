require 'rails_helper'
RSpec.describe :grouping, type: :system do
  describe "グルーピング変更機能" do
    let!(:mentor){create(:mentor, admin: true)}
    let!(:user){create(:user, :seq)}

    context "メンターが非メンバーのメンバーボタンを押した場合" do
      it "メンターのグループに追加される" do
        sign_in mentor
        visit users_path
        expect{
          find("#member-btn-#{user.id}").click
          # メンバー済みの表示に変わるまで待つ
          expect(page).to have_css "#member-btn-#{user.id} .material-icons", exact_text: "check_box"
        }.to change{mentor.group.member?(user)}.to(true)
      end
    end

    context "メンターがメンバーのメンバーボタンを押した場合" do
      it "メンターのグループから抜ける" do
        user.groupings.create(group: mentor.group)
        sign_in mentor
        visit users_path
        expect(page).to have_css "#member-btn-#{user.id} .material-icons", exact_text: "check_box"
        expect{
          find("#member-btn-#{user.id}").click
          # 非メンバーの表示に変わるまで待つ
          expect(page).to have_css "#member-btn-#{user.id} .material-icons", exact_text: "check_box_outline_blank"
        }.to change{mentor.group.member?(user)}.to(false)
      end
    end
  end
end
