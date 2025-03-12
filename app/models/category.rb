# == Schema Information
#
# Table name: categories
#
#  id        :integer          not null, primary key
#  name      :string           not null
#  parent_id :integer
#
# Indexes
#
#  index_categories_on_parent_id  (parent_id)
#
# Foreign Keys
#
#  parent_id  (parent_id => categories.id)
#
class Category < ApplicationRecord
  PUBLISHED_ID = 1.freeze
  DRAFTS_ID = 2.freeze

  has_many :children, class_name: "Category", foreign_key: "parent_id"
  belongs_to :parent, class_name: "Category", foreign_key: "parent_id", optional: true
  has_many :posts, dependent: :restrict_with_exception

  validates :name, presence: true
end
