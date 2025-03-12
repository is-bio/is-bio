# == Schema Information
#
# Table name: posts
#
#  id          :integer          not null, primary key
#  content     :string           not null
#  key         :integer          not null
#  permalink   :string           not null
#  title       :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  category_id :integer          default(2), not null
#
# Indexes
#
#  index_posts_on_category_id  (category_id)
#  index_posts_on_key          (key) UNIQUE
#
# Foreign Keys
#
#  category_id  (category_id => categories.id)
#
class Post < ApplicationRecord
  belongs_to :category

  validates :key, presence: true, uniqueness: true
  validates :permalink, presence: true
  validates :title, presence: true
  validates :content, presence: true

  before_validation :cleanup_title, :ensure_permalink, :ensure_key

  scope :published, -> { where(category_id: Category::ID_PUBLISHED) }

  def path
    "#{permalink}-#{key}"
  end

  private
    # TODO: Remove `""`
    def cleanup_title
      self.title = (title || "").strip
    end

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

    def ensure_key
      new_key = generate_key

      10.times do
        if self.class.where(key: new_key).exists?
          new_key = generate_key
          next
        end

        break
      end

      self.key = new_key
    end

    def generate_key
      if self.class.count >= 2000
        Random.rand(99999)
      else
        Random.rand(9999)
      end
    end
end
