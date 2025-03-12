class Category < ApplicationRecord
  PUBLISHED_ID = 1
  DRAFTS_ID = 2

  has_many :children, class_name: "Category", foreign_key: "parent_id"
  belongs_to :parent, class_name: "Category", foreign_key: "parent_id", optional: true

  validates :name, presence: true
end
