class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable

  has_one_attached :avatar do |attachable|
    attachable.variant :thumb, resize_to_limit: [200, 200]
  end

  validates :name, presence: true, length: {maximum: 255}
  validates :code, presence: true, length: {maximum: 6}
  validates :mentor, presence: true
  attribute :mentor, :string, default: false
  validates :entered_at, presence: true
  validates :admin, presence: true
  attribute :admin, :boolean, default: false
end
