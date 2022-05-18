class User < ApplicationRecord

  has_one_attached :avatar
  has_one :group, dependent: :destroy
  has_many :groupings, dependent: :destroy
  has_many :join_groups, through: :groupings, source: :group
  has_many :issues, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :favorite_issues, through: :favorites, source: :issue
  has_many :stocks, dependent: :destroy
  has_many :stock_issues, through: :stocks, source: :issue
  has_many :comments, dependent: :destroy
  has_many :comment_issues, through: :comments, source: :issue
  has_many :notifications, dependent: :destroy
  has_many :chat_room_users, dependent: :destroy
  has_many :chat_rooms, through: :chat_room_users, source: :chat_room
  acts_as_tagger

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable

  before_validation :code_to_6
  before_create :make_the_first_user_admin
  before_update :prevent_change_admin!
  before_destroy :prevent_destroy_admin!
  after_save_commit :group_create_or_destroy_depend_on_mentor

  validates :name, presence: true, length: {maximum: 255}
  validates :code, presence: true, length: {is: 6}, uniqueness: true
  attribute :mentor, :boolean, default: false
  validates :entered_at, presence: true
  attribute :admin, :boolean, default: false
  validate :validate_avatar_attachment_byte_size

  MAX_MEGA_BYTES = 2
  MAX_AVATAR_ATTACHMENT_BYTE_SIZE = MAX_MEGA_BYTES * (1_024 ** 2)

  def self.guest_admin_user
    find_or_create_by!(code: "_admin") do |user|
      user.name = "ゲスト管理者"
      user.email = "guest_admin@diver.com"
      user.entered_at = Date.new(2014, 4, 1)
      user.password = "password"
      user.mentor = true
      user.admin = true
    end
  end

  def self.guest_user
    find_or_create_by!(code: "_guest") do |user|
      user.name = "ゲスト"
      user.email = "guest@diver.com"
      user.entered_at = Date.new(Date.current.year, 4, 1)
      user.password = "password"
    end
  end

  def self.csv_columns
    { "No" => :id,
      "職員コード(6桁)" => :code,
      "名前" => :name,
      "Eメール" => :email,
      "パスワード(6文字以上)" => :password,
      "入職日(例:2000-04-01)" => :entered_at }
  end

  def group_member_issues
    return unless mentor?
    Issue.where(user_id: group.members&.pluck(:id))
  end

  def guest?
    [User.guest_user, User.guest_admin_user].include?(self)
  end

  scope :order_by_code, -> { order(:code) }


  private

  def prevent_change_admin!
    return unless admin_change == [true, false] && User.where(admin: true).size == 1
    errors.add(:base, I18n.t("activerecord.errors.messages.prevent_loss_of_admin"))
    raise ActiveRecord::Rollback
  end

  def prevent_destroy_admin!
    return unless admin? && User.where(admin: true).size == 1
    errors.add(:base, I18n.t("activerecord.errors.messages.prevent_loss_of_admin"))
    raise ActiveRecord::Rollback
  end

  def non_guest_user_is_empty?
    User.where("(code != ?) AND (code != ?)", "_admin", "_guest").blank? && %w[_admin _guest].exclude?(code)
  end

  def make_the_first_user_admin
    self.attributes = {mentor: true, admin: true} if non_guest_user_is_empty?
    self
  end

  def group_create_or_destroy_depend_on_mentor
    return group&.destroy unless mentor
    create_group! if group.nil?
  end

  def validate_avatar_attachment_byte_size
    if (attachment = avatar.attachment) && attachment.byte_size > MAX_AVATAR_ATTACHMENT_BYTE_SIZE
      errors.add(
        :base,
        :avatar_attachment_byte_size_is_too_large,
        max_avatar_attachment_mega_byte_size: MAX_MEGA_BYTES,
        bytes: attachment.byte_size,
        max_bytes: MAX_AVATAR_ATTACHMENT_BYTE_SIZE
      )
    end
  end

  def code_to_6
    self.code = code.to_s.rjust(6, "0") if code.present?
  end
end
