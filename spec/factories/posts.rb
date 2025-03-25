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
FactoryBot.define do
  factory :post do
    id { Faker::Lorem.characters(number: 4) }
    title { Faker::Lorem.words(number: 8).join.titleize }
    category_id { Category::ID_PUBLISHED }
    published_at { Time.current }
  end

  trait :drafts do
    after :build do |post|
      post.category_id = Category::ID_DRAFTS
    end
  end
end
