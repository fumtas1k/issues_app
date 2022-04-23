class Favorite < ApplicationRecord
  before_create :notify

  belongs_to :user
  belongs_to :issue, counter_cache: true
  has_one :notification, as: :subject, dependent: :destroy

  validates_uniqueness_of :issue_id, scope: :user_id

  # 通知を生成するメソッド(メソッド名共通)
  def notify
    return if user == issue.user
    build_notification do |note|
      note.user = issue.user
      note.message = Favorite.human_attribute_name(:notify_message, issue: issue.title, user: user.name)
      note.link_path = Rails.application.routes.url_helpers.issue_path(self.issue)
    end
  end
end
