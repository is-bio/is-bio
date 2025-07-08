# == Schema Information
#
# Table name: social_media_accounts
#
#  id         :integer          not null, primary key
#  key        :string           not null
#  value      :string
#  updated_at :datetime
#
# Indexes
#
#  index_social_media_accounts_on_key  (key) UNIQUE
#
FactoryBot.define do
  factory :social_media_account do
    sequence(:key) { |n| "website_url#{n}" }
    sequence(:value) { |n| "https://example#{n}.com" }

    trait :email do
      key { "email" }
      sequence(:value) { |n| "user#{n}@example.com" }
      # 或者使用 Faker:
      # value { Faker::Internet.unique.email }
    end

    trait :phone do
      key { "phone_number" }
      sequence(:value) { |n| "+1 #{800 + n}-555-#{1000 + n}" }
      # 或者使用 Faker:
      # value { Faker::PhoneNumber.unique.cell_phone_in_e164 }
    end

    trait :github do
      key { "github_username" }
      sequence(:value) { |n| "github-user-#{n}" }
      # 或者使用 Faker:
      # value { Faker::Internet.unique.username(specifier: 5..10) }
    end

    trait :x_twitter do
      key { "x_username" }
      sequence(:value) { |n| "x-user-#{n}" }
      # 或者使用 Faker:
      # value { Faker::Internet.unique.username(specifier: 5..10) }
    end

    trait :linkedin do
      key { "linkedin_profile_url" }
      sequence(:value) { |n| "https://www.linkedin.com/in/user-profile-#{n}/" }
    end

    trait :website do
      key { "website_url" }
      value { Faker::Internet.unique.url }
      # sequence(:value) { |n| "https://example#{n}.com" }
      # 或者使用 Faker:
      # value { Faker::Internet.unique.url }
    end
  end
end
