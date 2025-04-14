# == Schema Information
#
# Table name: post_variants
#
#  id         :integer          not null, primary key
#  title      :text
#  content    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  post_id    :integer          not null
#  locale_id  :integer          not null
#
# Indexes
#
#  index_post_variants_on_post_id     (post_id)
#  index_post_variants_on_locale_id   (locale_id)
#
# Foreign Keys
#
#  post_id    (post_id => posts.id)
#  locale_id  (locale_id => locales.id)
#
class PostVariant < ApplicationRecord
  belongs_to :post
  belongs_to :locale

  validates :post_id, presence: true
  validates :locale_id, presence: true
  validates :post_id, uniqueness: { scope: :locale_id, message: "already has a post (variant) for this locale" }
end
