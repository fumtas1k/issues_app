require 'rails_helper'

RSpec.describe Ability, type: :model do
  let(:target) { create(:user, :seq) }

  describe "非ゲストの管理者" do
    let(:admin) { create(:admin) }
    subject(:ability) { Ability.new(admin) }

    it "rails_adminにアクセスでき、全モデルを操作できる" do
      expect(ability).to be_able_to(:access, :rails_admin)
      expect(ability).to be_able_to(:manage, target)
      expect(ability).to be_able_to(:destroy, target)
    end

    it "一般ユーザーのメンターを切り替えられる" do
      expect(ability).to be_able_to(:toggle_mentor, target)
    end

    it "メンターの一般ユーザーのメンターも切り替えられる" do
      target.update!(mentor: true)
      expect(ability).to be_able_to(:toggle_mentor, target)
    end

    it "管理者のメンターは切り替えられない" do
      other_admin = create(:user, :seq, admin: true)
      expect(ability).not_to be_able_to(:toggle_mentor, other_admin)
      expect(ability).not_to be_able_to(:toggle_mentor, admin)
    end

    it "ゲストのメンターは切り替えられない" do
      expect(ability).not_to be_able_to(:toggle_mentor, User.guest_user)
      expect(ability).not_to be_able_to(:toggle_mentor, User.guest_admin_user)
    end
  end

  describe "ゲスト管理者" do
    subject(:ability) { Ability.new(User.guest_admin_user) }

    it "rails_adminにアクセスでき、閲覧のみできる" do
      expect(ability).to be_able_to(:access, :rails_admin)
      expect(ability).to be_able_to(:read, :dashboard)
      expect(ability).to be_able_to(:index, User)
      expect(ability).to be_able_to(:show, target)
    end

    it "作成・更新・削除・エクスポート・一括削除はできない" do
      %i[create new update edit destroy delete export bulk_delete].each do |action|
        expect(ability).not_to be_able_to(action, target), "#{action} が許可されている"
      end
    end

    it "メンターを切り替えられない" do
      expect(ability).not_to be_able_to(:toggle_mentor, target)
    end
  end

  describe "管理者以外" do
    it "メンターは何もできない" do
      ability = Ability.new(create(:mentor))
      expect(ability).not_to be_able_to(:access, :rails_admin)
      expect(ability).not_to be_able_to(:toggle_mentor, target)
      expect(ability).not_to be_able_to(:read, target)
    end

    it "一般ユーザー・ゲストは何もできない" do
      [create(:user), User.guest_user].each do |user|
        ability = Ability.new(user)
        expect(ability).not_to be_able_to(:access, :rails_admin)
        expect(ability).not_to be_able_to(:toggle_mentor, target)
      end
    end

    it "未ログインは何もできない" do
      ability = Ability.new(nil)
      expect(ability).not_to be_able_to(:access, :rails_admin)
      expect(ability).not_to be_able_to(:toggle_mentor, target)
    end
  end
end
