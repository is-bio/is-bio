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

  has_many :translations, dependent: :destroy
  has_many :locales, through: :translations

  # has_many :comments # TODO: should not delete comments if 'id2' changed or post deleted.

  validates :permalink, presence: true
  validates :published_at, presence: true
  validate :permalink_starts_with
  validate :id2_format

  before_validation :cleanup_columns, :ensure_permalink
  before_validation :ensure_id2, :ensure_published_at, on: :create
  before_save :ensure_different_published_at
  after_save :ensure_permalink_if_missing

  scope :published, -> { where(category_id: Category.published_ids) }

  def self.sync_from_file_contents!(status, filename, contents)
    metadata = YAML.load(contents) || {}

    id2 = (metadata["id"] || "").strip
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

    unless id2.match?(/\A[a-zA-Z0-9_]+\z/)
      return
    end

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
        if post.present? # "id2" changed
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

  def self.available_locales
    available_locale_keys = I18n.available_locales - [ I18n.locale ]
    where(key: available_locale_keys.map(&:to_s))
  end

  def path
    "/blog#{permalink}-#{id2}"
  end

  def translated!
    return if I18n.locale == I18n.default_locale

    translation = current_translation

    if translation.present?
      self.title = translation.title
      self.content = translation.content
    else
      self.title = I18n.t("post.no_title")
      self.content = I18n.t("post.no_content", language: I18n.locale.to_s)
    end
  end

  def current_translation
    translations.find_by(
      locale: Locale.find_by(key: I18n.locale)
    )
  end

  private

  def id2_format
    if id2.present? && !id2.match?(/\A[a-zA-Z0-9_]+\z/)
      errors.add :id2, 'is invalid! Only letters, numbers and "_" are valid characters.'
    end
  end

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

  def ensure_permalink
    perma_link = (permalink || "").strip

    if perma_link.blank? || perma_link == "/"
      self.permalink = generate_permalink
    else
      # Remove the first '/' if it starts with '/'
      if perma_link.start_with?("/")
        perma_link = perma_link[1..]
      end

      # Replace special characters with hyphens while preserving case
      perma_link.gsub!(/[^a-zA-Z0-9\-]/, "-")

      self.permalink = refined_permalink(perma_link)
    end
  end

  def generate_permalink
    return "/" if title.blank?

    refined_permalink(
      title.downcase.gsub(/[^a-z0-9]/, "-") # Convert to lowercase and replace other characters with hyphens
    )
  end

  def refined_permalink(permalink)
    # Replace multiple consecutive hyphens with a single hyphen
    permalink = permalink.gsub(/-+/, "-")

    # Remove the starting and trailing hyphen
    permalink.chomp!("-")
    if permalink.start_with?("-")
      permalink.sub!("-", "/")
    end

    unless permalink.start_with?("/")
      permalink = "/#{permalink}"
    end

    if permalink.length > 255
      permalink = permalink[0..254]
    end

    permalink
  end

  def ensure_permalink_if_missing
    if permalink == "/"
      update_columns(permalink: "/#{id}")
    end
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

  def ensure_different_published_at
    return if published_at.nil?

    current_timestamp = published_at

    while Post.where(published_at: current_timestamp)
              .where.not(id: id.to_i)
              .exists?
      # If collision exists, add 1 second and check again
      current_timestamp += 1.second
    end

    if current_timestamp != published_at
      self.published_at = current_timestamp
    end
  end
end
