class Notification < ApplicationRecord
  belongs_to :subject, polymorphic: true
  belongs_to :user

  validates :message, presence: true
  validates :link_path, presence: true

  scope :unreads, -> { where(read: false) }
end
