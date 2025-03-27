# == Schema Information
#
# Table name: github_app_settings
#
#  id         :integer          not null, primary key
#  key        :string           not null
#  value      :string
#  updated_at :datetime
#
# Indexes
#
#  index_github_app_settings_on_key  (key) UNIQUE
#
FactoryBot.define do
  factory :github_app_setting do
    key { Faker::Lorem.words(number: 3).join("_").downcase }
    value { Faker::Lorem.words(number: 3).join }
  end
end
