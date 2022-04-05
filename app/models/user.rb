class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable

  has_one_attached :avatar

  validates :name, presence: true, length: {maximum: 255}
  validates :code, presence: true, length: {is: 6}
  attribute :mentor, :boolean, default: false
  validates :entered_at, presence: true
  attribute :admin, :boolean, default: false
end
