class Issue < ApplicationRecord
  extend GetEnumMethod
  def_human_enum_ :status, :scope

  belongs_to :user
  has_rich_text :description

  validates :title, presence: true, length: {maximum: 30}
  validates :description, presence: true
  validates :status, presence: true
  enum status: %i[pending solving]
  validates :scope, presence: true
  enum scope: %i[release limited draft] # publicは使用できないためreleaseとした

end
