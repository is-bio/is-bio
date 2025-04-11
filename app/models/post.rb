# == Schema Information
#
# Table name: posts
#
#  id           :integer          not null, primary key
#  content      :text
#  filename     :text
#  id2          :string
#  permalink    :string           not null
#  published_at :datetime         not null
#  thumbnail    :string
#  title        :text
#  updated_at   :datetime
#  category_id  :integer          not null
#
# Indexes
#
#  index_posts_on_category_id  (category_id)
#  index_posts_on_id2          (id2) UNIQUE
#
# Foreign Keys
#
#  category_id  (category_id => categories.id)
#
# noinspection RubyMismatchedArgumentType
class Post < ApplicationRecord
  DEFAULT_TITLE = "No Title"

  belongs_to :category
  # has_many :comments # TODO: should not delete comments if 'id2' changed or post deleted.

  validates :permalink, presence: true
  validates :published_at, presence: true
  validate :permalink_starts_with

  before_validation :cleanup_columns, :ensure_permalink
  before_validation :ensure_id2, :ensure_published_at, on: :create

  scope :published, -> { where(category_id: Category.published_ids) }

  def path
    "#{permalink}-#{id2}"
  end

  def self.sync_from_file_contents!(status, filename, contents)
    metadata = YAML.load(contents) || {}

    id2 = metadata["id"]
    permalink = metadata["permalink"]
    title = metadata["title"]
    date = metadata["date"]
    thumbnail = metadata["thumbnail"]

    unless id2.present?
      if status == "modified"
        post = Post.find_by(filename: filename)
        if post.present?
          post.destroy!
        end
      end
      return
    end

    match = /---.*?---(.*)/m.match(contents)
    if match.nil?
      content = nil
    else
      content = match[1].strip
    end

    id2.gsub!("-", "_")
    post = Post.find_by(id2: id2)
    category = Category.prepared_category(filename)

    if status == "renamed"
      if post.present?
        post.update!(
          filename: filename,
          category: category,
        )
        return post
      end
    end

    if post.nil?
      if status == "modified"
        post = Post.find_by(filename: filename)
        if post.present?
          attributes = {
            id2: id2,
            permalink: permalink,
            filename: filename,
            category: category,
            title: title,
            thumbnail: thumbnail,
            content: content
          }
          begin
            attributes.merge!(published_at: date.to_datetime)
          rescue
            # Do nothing
          end
          post.update!(attributes)
          return post
        end
      end

      post = Post.create!(
        filename: filename,
        id2: id2,
        category: category,
        permalink: permalink,
        title: title,
        published_at: date,
        thumbnail: thumbnail,
        content: content
      )
      post
    else
      attributes = {
        filename: filename,
        category: category,
        permalink: permalink,
        title: title,
        thumbnail: thumbnail,
        content: content
      }
      begin
        attributes.merge!(published_at: date.to_datetime)
      rescue
        # Do nothing
      end
      post.update!(attributes)
      post
    end
  end

  private

  def permalink_starts_with
    unless permalink.start_with?("/")
      errors.add :permalink, 'should starting with "/"'
    end
  end

  # TODO: Remove `""`
  def cleanup_columns
    if id2.present? && id2.include?("-")
      self.id2 = id2.gsub("-", "_")
    end

    title = (self.title || "").strip
    self.title = title.blank? ? DEFAULT_TITLE : title
    if self.content.nil?
      self.content = ""
    end
    self.content.strip!

    if self.thumbnail.blank?
      self.thumbnail = nil
    end
  end

  # TODO: Should not contain `/` in the middle?
  def ensure_permalink
    permanent_link = (permalink || "").strip

    if permanent_link.blank? || permanent_link == "/"
      self.permalink = generate_permalink
    else
      # Remove all invalid characters, only allow letters, digits, underscore, hyphen and space
      permanent_link = permanent_link.gsub(/[^a-zA-Z0-9_\s-]/, "")
      # Replace spaces and underscores with hyphens
      permanent_link = permanent_link.gsub(/[\s_]+/, "-")

      if permanent_link[0] != "/"
        permanent_link = "/" + permanent_link
      end

      self.permalink = permanent_link
    end
  end

  def generate_permalink
    # Remove all invalid characters, only allow letters, digits, underscore, hyphen and space
    sanitized = title.to_s.gsub(/[^a-zA-Z0-9_\s-]/, "").strip
    # Replace spaces and underscores with hyphens and limit length
    "/" + sanitized.gsub(/[\s_]+/, "-").downcase[...255]
  end

  def ensure_id2
    if id2.present?
      return
    end

    new_id2 = generate_id2

    10.times do
      if self.class.find_by(id2: new_id2).present?
        new_id2 = generate_id2
        next
      end

      break
    end

    self.id2 = new_id2
  end

  def generate_id2
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    3.times.map { chars.sample }.join
  end

  def ensure_published_at
    self.published_at =
      if published_at.blank?
        Time.current
      else
        begin
          self.published_at.to_datetime
        rescue
          Time.current
        end
      end
  end
end
