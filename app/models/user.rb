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

  private

  def prevent_loss_of_admin!
    return if User.where(admin: true).exists?
    errors.add(:base, I18n.t("activerecord.errors.messages.prevent_loss_of_admin"))
    raise ActiveRecord::Rollback
  end
end
