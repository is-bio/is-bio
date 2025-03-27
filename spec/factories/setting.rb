# == Schema Information
#
# Table name: settings
#
#  id         :integer          not null, primary key
#  key        :string           not null
#  value      :string
#  updated_at :datetime
#
# Indexes
#
#  index_settings_on_key  (key) UNIQUE
#
FactoryBot.define do
  factory :setting do
    sequence(:key) { |n| "setting_key_#{n}" }
    value { "sample value" }

    trait :github_username do
      sequence(:key) { "github_username" }
      value { "github-user" }
    end

    trait :empty_value do
      sequence(:key) { |n| "empty_setting_#{n}" }
      value { nil }
    end
  end
end
