class Comment < ApplicationRecord
  include SqlHelper
  extend ActionTextValidate

  belongs_to :user
  belongs_to :issue
  has_rich_text :content
  has_one :_content, class_name: "ActionText::RichText", as: :record
  has_one :notification, as: :subject, dependent: :destroy

  validates :content, presence: true
  validate :validate_content_attachment_byte_size

  MAX_MEGA_BYTES = 5
  create_validate_attachment :content, MAX_MEGA_BYTES

  # 通知を生成するメソッド(メソッド名共通)
  def notify
    return if user == issue.user
    create_notification do |note|
      note.user = issue.user
      note.message = Comment.human_attribute_name(:notify_message, issue: issue.title, user: user.name)
      note.link_path = Rails.application.routes.url_helpers.issue_path(issue)
    end
  end
end
