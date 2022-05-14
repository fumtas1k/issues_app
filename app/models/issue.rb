class Issue < ApplicationRecord
  include SqlHelper
  extend GetEnumMethod
  extend ActionTextValidate

  before_update :notify
  after_create_commit :notify

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
  acts_as_taggable_on :tags

  validates :title, presence: true, length: {maximum: 30}
  validates :description, presence: true
  validates :status, presence: true
  enum status: %i[pending solving]
  validates :scope, presence: true
  enum scope: %i[release limited draft] # publicは使用できないためreleaseとした
  validate :validate_description_attachment_byte_size

  MAX_MEGA_BYTES = 5
  create_validate_attachment :description, MAX_MEGA_BYTES

  # scopeとmentorによりアクセス可能かを判定するメソッド
  def accessible?(login_user)
    return true if scope == "release" || user == login_user
    return false if scope == "draft" || !login_user.mentor
    login_user.group.member?(user)
  end

  # 通知を生成するメソッド(メソッド名共通)
  def notify
    groups = user.join_groups
    return if scope == "draft" || groups.blank?
    notify_message =
      if scope_change&.dig(0) == "draft" || notifications.blank?
        Issue.human_attribute_name(:notify_message, issue: title, user: user.name)
      elsif status_change == %w[pending solving]
        Issue.human_attribute_name(:solving_notify_message, issue: title, user: user.name)
      end
    return unless notify_message
    groups.map do |group|
      notifications.create do |note|
        note.user = group.user
        note.message = notify_message
        note.link_path = Rails.application.routes.url_helpers.issue_path(self)
      end
    end
  end
end
