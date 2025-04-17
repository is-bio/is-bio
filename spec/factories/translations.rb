# == Schema Information
#
# Table name: translations
#
#  id         :integer          not null, primary key
#  content    :text
#  title      :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  locale_id  :integer          not null
#  post_id    :integer          not null
#
# Indexes
#
#  index_translations_on_locale_id  (locale_id)
#  index_translations_on_post_id    (post_id)
#
# Foreign Keys
#
#  locale_id  (locale_id => locales.id)
#  post_id    (post_id => posts.id)
#
FactoryBot.define do
  factory :translation do
    title { "Translation Title" }
    content { "Translation Content" }
    association :post
    association :locale
  end
end
