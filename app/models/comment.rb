class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :issue
  has_rich_text :content
  has_one :notification, as: :subject, dependent: :destroy

  validates :content, presence: true

  # 通知を生成するメソッド(メソッド名共通)
  def notify
    create_notification do |note|
      note.user = issue.user
      note.message = Comment.human_attribute_name(:notify_message, issue: issue.title, user: user.name)
      note.link_path = Rails.application.routes.url_helpers.issue_path(issue)
    end
  end
end
