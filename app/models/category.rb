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
  ID_PUBLISHED = 1.freeze
  ID_DRAFTS = 2.freeze

  has_ancestry
  has_many :posts, dependent: :restrict_with_exception

  validates :name, presence: true

  scope :published_ids, -> { find(ID_PUBLISHED).descendant_ids << ID_PUBLISHED }

  def path
    "/category/#{url_safe_name}-#{id}"
  end

  def url_safe_name
    CGI.escape(name.downcase.split(" ").join("-"))
  end
end
