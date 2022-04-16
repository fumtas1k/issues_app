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

    context "既に登録されているcodeを入力した場合" do
      let!(:code_user){ create(:user, :seq, code: user.code)}
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

    context "既に登録されているemailを入力した場合" do
      let!(:email_user){ create(:user, :seq, email: user.email)}
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

  describe "最初のユーザーを管理者にするコールバックのテスト" do
    let(:user) {create(:user)}
    context "ユーザーが0人の時にアカウント登録した場合" do
      it "管理者権限を持つ" do
        expect(user.admin).to be_truthy
      end
    end
    context "ゲストユーザー以外いない状態でアカウント登録した場合" do
      it "管理者権限を持つ" do
        User.guest_user
        User.guest_admin_user
        expect(user.admin).to be_truthy
      end
    end
    context "ゲスト以外のユーザーが1人いる状態でアカウント登録した場合" do
      it "管理者権限は持たない" do
        FactoryBot.create(:user,:seq)
        expect(user.admin).to be_falsey
      end
    end
  end

  describe "管理者を0人にしないコールバックのテスト" do
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

  describe "グループを作成、削除するコールバックのテスト" do
    let!(:admin){create(:admin)}
    let(:mentor){build(:mentor)}
    let(:user){build(:user)}

    context "メンターを作成した場合" do
      it "そのメンターのグループが作成される" do
        expect{mentor.save}.to change{Group.count}.by(1)
      end
    end

    context "メンターから一般ユーザーに変更した場合" do
      it "グループも削除される" do
        expect{mentor.save}.to change{Group.count}.by(1)
        expect{mentor.toggle!(:mentor)}.to change{Group.count}.by(-1)
        mentor.reload
        expect(mentor.group).to be nil
      end
    end

    # メンターがユーザー情報を更新すると、
    # groupが再生成されるロジックになっていた。それが、修正されたかの確認用
    context "メンターの情報を更新した場合" do
      it "グループ情報は変更されない" do
        mentor.save
        expect{mentor.update(admin: true)}.not_to change{mentor.group}
      end
    end

    context "ユーザーを作成した場合" do
      it "グループは作成されない" do
        expect{user.save}.to change{Group.count}.by(0)
      end
    end
  end
end
