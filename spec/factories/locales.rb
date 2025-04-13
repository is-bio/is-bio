# == Schema Information
#
# Table name: locales
#
#  id           :integer          not null, primary key
#  english_name :string           not null
#  key          :string           not null
#  name         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_locales_on_english_name  (english_name) UNIQUE
#  index_locales_on_name          (name) UNIQUE
#
FactoryBot.define do
  factory :locale do
    sequence(:key) { |n| "xx-#{format('%03d', n)[0..2].upcase}" }
    sequence(:english_name) { |n| "Test Language #{n}" }
    sequence(:name) { |n| "Test Language Value #{n}" }

    # Trait for English locale
    trait :english do
      key { "en" }
      english_name { "English" }
      name { "English" }
    end

    # Factory method to create locale with specific key
    factory :locale_with_key do
      transient do
        locale_key { "custom" }
        locale_english_name { "Custom Language" }
        locale_name { "Custom Language Name" }
      end

      key { locale_key }
      english_name { locale_english_name }
      name { locale_name }
    end
  end
end
