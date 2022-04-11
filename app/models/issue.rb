class Issue < ApplicationRecord
  extend GetEnumMethod
  def_human_enum_ :status, :scope

  belongs_to :user
  has_rich_text :description
  has_many :favorites, dependent: :destroy
  has_many :favorite_users, through: :favorites, source: :user
  has_many :stocks, dependent: :destroy
  has_many :stock_users, through: :stocks, source: :user
  has_many :comments, dependent: :destroy
  has_many :comment_users, through: :comments, source: :user

  validates :title, presence: true, length: {maximum: 30}
  validates :description, presence: true
  validates :status, presence: true
  enum status: %i[pending solving]
  validates :scope, presence: true
  enum scope: %i[release limited draft] # publicは使用できないためreleaseとした

  acts_as_taggable_on :tags

  def accessible?(login_user)
    return true if scope == "release" || user == login_user
    return false if scope == "draft" || !login_user.mentor
    login_user.group.member?(user)
  end
end
