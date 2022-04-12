class Issue < ApplicationRecord
  include SqlHelper
  extend GetEnumMethod

  def_human_enum_ :status, :scope

  belongs_to :user
  has_rich_text :description
  has_one :_description, class_name: "ActionText::RichText", as: :record
  has_many :favorites, dependent: :destroy
  has_many :favorite_users, through: :favorites, source: :user
  has_many :stocks, dependent: :destroy
  has_many :stock_users, through: :stocks, source: :user
  has_many :comments, dependent: :destroy
  has_many :comment_users, through: :comments, source: :user
  has_many :notifications, as: :subject, dependent: :destroy

  validates :title, presence: true, length: {maximum: 30}
  validates :description, presence: true
  validates :status, presence: true
  enum status: %i[pending solving]
  validates :scope, presence: true
  enum scope: %i[release limited draft] # publicは使用できないためreleaseとした

  acts_as_taggable_on :tags

  # scopeとmentorによりアクセス可能かを判定するメソッド
  def accessible?(login_user)
    return true if scope == "release" || user == login_user
    return false if scope == "draft" || !login_user.mentor
    login_user.group.member?(user)
  end

  # 通知を生成するメソッド(メソッド名共通)
  def notify(before_status=nil)
    if scope != "draft" && (groups = user.join_groups.presence)
      notify_message =
        if before_status.nil?
          Issue.human_attribute_name(:notify_message, issue: title, user: user.name)
        elsif [before_status, status] == %w[pending solving]
          Issue.human_attribute_name(:solving_notify_message, issue: title, user: user.name)
        end
      groups.map do |group|
        notifications.create do |note|
          note.user = group.user
          note.message = notify_message
          note.link_path = Rails.application.routes.url_helpers.issue_path(self)
        end
      end
    end
  end
end
