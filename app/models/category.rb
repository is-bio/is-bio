# == Schema Information
#
# Table name: categories
#
#  id       :integer          not null, primary key
#  ancestry :string           not null
#  name     :string           not null
#
# Indexes
#
#  index_categories_on_ancestry  (ancestry)
#
# noinspection ALL
class Category < ApplicationRecord
  ID_PUBLISHED = 1.freeze
  ID_DRAFTS = 2.freeze

  has_ancestry

  has_many :posts, dependent: :restrict_with_exception

  validates :name, presence: true

  def self.published_ids
    find(ID_PUBLISHED).descendant_ids << ID_PUBLISHED
  end

  def self.drafts_ids
    find(ID_DRAFTS).descendant_ids << ID_DRAFTS
  end

  def self.published_root
    find(ID_PUBLISHED)
  end

  def self.drafts_root
    find(ID_DRAFTS)
  end

  def self.find_by_name(name)
    where(id: published_ids).each do |category|
      if category.path_name == name
        return category
      end
    end

    nil
  end

  def self.find_by_name_from_drafts(name)
    where(id: drafts_ids).each do |category|
      if category.path_name == name
        return category
      end
    end

    nil
  end

  def self.prepared_category(filename)
    unless Directory.published_or_drafts?(filename)
      return
    end

    filename = filename.clone
    published = false

    if filename.start_with?("published/")
      filename.sub!("published/", "")
      published = true
    else
      filename.sub!("drafts/", "")
    end

    category = nil
    parent = published ? published_root : drafts_root
    category_names = filename.split("/")[...-1]

    category_names.each_with_index do |category_name, i|
      if i > 0
        parent = category
      end

      parent.children.reload # Notice: Must have this line to prevent multiple background jobs from creating the same category twice.

      category = parent.children.where(
        name: standardized_category_name(category_name),
      ).first_or_create!
    end

    category || parent
  end

  def self.standardized_category_name(category_name)
    words = category_name.split.join("-").gsub("_", "-").split("-")

    # Capitalize the first letter of each word while preserving the rest
    words.map { |word| word[0].upcase + word[1..-1] }.join("-")
  end

  def path
    # if id == Category::ID_PUBLISHED
    #   return "/categories"
    # end
    #
    # if id == Category::ID_DRAFTS
    #   return "/drafts"
    # end

    if Category.drafts_ids.include?(id)
      return "/drafts/#{path_name}"
    end

    "/category/#{path_name}"
  end

  def path_name
    CGI.escape(name.downcase)
  end
end
