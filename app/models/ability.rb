# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return if user.nil?
    return unless user.admin?

    if user.guest?
      # ゲスト管理者は閲覧専用（作成・更新・削除・エクスポート・メンター切り替えは不可）
      can :access, :rails_admin
      can :read, :dashboard
      can :dashboard, :all
      can :read, :all
    else
      can :access, :rails_admin
      can :manage, :all
      # メンターの切り替えは、管理者でもゲストでもないユーザーのみ対象にできる
      cannot :toggle_mentor, User
      can :toggle_mentor, User do |target|
        !target.admin? && !target.guest?
      end
    end
  end
end
