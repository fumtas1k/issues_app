class Issue < ApplicationRecord
  belongs_to :user

  has_rich_text :description

  validates :title, presence: true, length: {maximum: 30}
  validates :description, presence: true
  validates :status, presence: true
  enum status: %i[pending solving]
  validates :scope, presence: true
  enum scope: %i[release limited draft] # publicは使用できないためreleaseとした

  def self.human_attribute_enum_name(attr_name, value)
    human_attribute_name("#{attr_name}.#{value}")
  end

  def self.enum_options_for_select(attr_name)
    self.send(attr_name.to_s.pluralize).reduce({}) do |hash, (key, _)|
      hash.merge({self.human_attribute_enum_name(attr_name, key) => key})
    end
  end
end
