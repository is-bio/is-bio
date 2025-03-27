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
    key { "website_url" }
    value { "https://example.com" }

    trait :email do
      key { "email" }
      value { "user@example.com" }
    end

    trait :phone do
      key { "phone_number" }
      value { "+1 123-456-7890" }
    end

    trait :github do
      key { "github_username" }
      value { "github-user" }
    end

    trait :x_twitter do
      key { "x_username" }
      value { "twitter_handle" }
    end

    trait :linkedin do
      key { "linkedin_profile_url" }
      value { "https://www.linkedin.com/in/user-profile/" }
    end

    trait :website do
      key { "website_url" }
      value { "https://example.com" }
    end
  end
end
