# == Schema Information
#
# Table name: posts
#
#  id           :string           not null, primary key
#  content      :text
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
  belongs_to :category

  validates :permalink, presence: true
  validates :title, presence: true
  validates :published_at, presence: true
  validate :permalink_starts_with

  before_validation :cleanup_title, :ensure_permalink
  before_validation :ensure_id, on: :create

  scope :published, -> { where(category_id: Category.published_ids) }

  def path
    "#{permalink}-#{id}"
  end

  def self.create_from_file_contents!(filename, contents)
    metadata = YAML.load(contents) || {}

    id = metadata["id"]
    title = metadata["title"]
    date = metadata["date"]

    unless id.present? && title.present?
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

    if post.nil?
      Post.create!(
        id: id,
        category: category,
        title: title,
        published_at: date,
        content: content
      )
    else
      post.update!(
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
  def cleanup_title
    self.title = (title || "").strip
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
    "/" + CGI.escape(title.downcase.split(" ").join("-"))
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
