# == Schema Information
#
# Table name: posts
#
#  id           :string           not null, primary key
#  content      :text
#  filename     :text
#  permalink    :string           not null
#  published_at :datetime         not null
#  title        :string           not null
#  updated_at   :datetime
#  category_id  :integer          not null
#
# Indexes
#
#  index_posts_on_category_id  (category_id)
#
# Foreign Keys
#
#  category_id  (category_id => categories.id)
#
# noinspection RubyMismatchedArgumentType
class Post < ApplicationRecord
  DEFAULT_TITLE = "No Title"

  belongs_to :category
  # has_many :comments # TODO: should not delete comments if 'id' changed or post deleted.

  validates :permalink, presence: true
  validates :published_at, presence: true
  validate :permalink_starts_with

  before_validation :cleanup_columns, :ensure_permalink
  before_validation :ensure_id, on: :create

  scope :published, -> { where(category_id: Category.published_ids) }

  def path
    "#{permalink}-#{id}"
  end

  def self.sync_from_file_contents!(status, filename, contents)
    metadata = YAML.load(contents) || {}

    id = metadata["id"]
    title = metadata["title"]
    date = metadata["date"]

    unless id.present?
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

    post = Post.find_by(id: id)
    category = Category.prepared_category(filename)

    if status == "renamed"
      if post.present?
        post.update!(
          filename: filename,
          category: category,
        )
        return
      end
    end

    if post.nil?
      if status == "modified"
        post = Post.find_by(filename: filename)
        if post.present?
          post.update!(
            id: id,
            filename: filename,
            category: category,
            title: title,
            published_at: date,
            content: content
          )
          return
        end
      end

      Post.create!(
        filename: filename,
        id: id,
        category: category,
        title: title,
        published_at: date,
        content: content
      )
    else
      post.update!(
        filename: filename,
        category: category,
        title: title,
        published_at: date,
        content: content
      )
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
    title = (self.title || "").strip
    self.title = title.blank? ? DEFAULT_TITLE : title
    self.content = (content || "").strip
  end

  # TODO: Should not contain `/` in the middle?
  def ensure_permalink
    permanent_link = (permalink || "").strip

    if permanent_link.blank? || permanent_link == "/"
      self.permalink = generate_permalink
    else
      if permanent_link[0] != "/"
        permanent_link = "/" + permanent_link
      end

      self.permalink = permanent_link
    end
  end

  def generate_permalink
    # TODO: Remove all invalid chars
    "/" + CGI.escape(title.to_s.downcase.split(" ").join("-")[...255])
  end

  def ensure_id
    if id.present?
      return
    end

    new_id = generate_id

    10.times do
      if self.class.find_by(id: new_id).present?
        new_id = generate_id
        next
      end

      break
    end

    self.id = new_id
  end

  def generate_id
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    3.times.map { chars.sample }.join
  end
end
