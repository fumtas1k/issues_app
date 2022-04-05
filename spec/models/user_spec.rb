require 'rails_helper'

RSpec.describe User, type: :model do
  describe "バリデーションのテスト" do
    let(:user) { build(:user) }
    shared_examples "バリデーションに引っかかる" do
      it {expect(user).to_not be_valid}
    end

    context "必須事項を入力した場合" do
      it "バリデーションが通る" do
        expect(user).to be_valid
      end
    end

    context "名前が空白の場合" do
      before {user.name = ""}
      it_behaves_like "バリデーションに引っかかる"
    end

    context "codeが空白の場合" do
      before {user.code = ""}
      it_behaves_like "バリデーションに引っかかる"
    end

    context "codeが5文字の場合" do
      before {user.code = "12345"}
      it_behaves_like "バリデーションに引っかかる"
    end

    context "codeが7文字の場合" do
      before {user.code = "1234567"}
      it_behaves_like "バリデーションに引っかかる"
    end

    context "emailが空白の場合" do
      before {user.email = ""}
      it_behaves_like "バリデーションに引っかかる"
    end

    context "emailが不正の場合" do
      before {user.email = "a@"}
      it_behaves_like "バリデーションに引っかかる"
      before {user.email = "a.a.com"}
      it_behaves_like "バリデーションに引っかかる"
    end

    context "entered_atが空白の場合" do
      before {user.entered_at = ""}
      it_behaves_like "バリデーションに引っかかる"
    end

    context "passwordが空白の場合" do
      before {user.password = ""}
      it_behaves_like "バリデーションに引っかかる"
    end

    context "passwordが5文字の場合" do
      before {user.password = "passw"}
      it_behaves_like "バリデーションに引っかかる"
    end
  end

  describe "コールバックのテスト" do
    let!(:admin){create(:admin)}
    context "管理者が2人いる時、管理者1人削除した場合" do
      it "削除できる" do
        FactoryBot.create(:user,:seq, admin: true)
        expect{admin.destroy}.to change{User.count}.by(-1)
      end
    end

    context "管理者が2人いる時、管理者1人を非管理者に変更した場合" do
      it "変更できる" do
        FactoryBot.create(:user,:seq, admin: true)
        expect{admin.toggle!(:admin)}.to change{User.where(admin: true).count}.by(-1)
      end
    end

    context "管理者が1人の時、管理者1人削除した場合" do
      it "削除できない" do
        expect{admin.destroy}.to change{User.count}.by(0)
      end
    end
    context "管理者が1人の時、管理者1人を非管理者に変更した場合" do
      it "変更できない" do
        expect{admin.toggle!(:admin)}.to change{User.where(admin: true).count}.by(0)
      end
    end

  end
end
