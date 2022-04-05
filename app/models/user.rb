class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  after_update :prevent_loss_of_admin!
  after_destroy :prevent_loss_of_admin!

  has_one_attached :avatar

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable

  validates :name, presence: true, length: {maximum: 255}
  validates :code, presence: true, length: {is: 6}
  attribute :mentor, :boolean, default: false
  validates :entered_at, presence: true
  attribute :admin, :boolean, default: false

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

  private

  def prevent_loss_of_admin!
    return if User.where(admin: true).exists?
    errors.add(:base, I18n.t("activerecord.errors.messages.prevent_loss_of_admin"))
    raise ActiveRecord::Rollback
  end

end
