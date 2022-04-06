class Group < ApplicationRecord
  belongs_to :user
  has_many :groupings, dependent: :destroy
  has_many :members, through: :groupings, source: :user

  def member?(user)
    members.include?(user)
  end
end
