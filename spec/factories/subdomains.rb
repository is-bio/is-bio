# == Schema Information
#
# Table name: subdomains
#
#  id         :integer          not null, primary key
#  value      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  locale_id  :integer          not null
#
# Indexes
#
#  index_subdomains_on_locale_id  (locale_id)
#  index_subdomains_on_value      (value) UNIQUE
#
# Foreign Keys
#
#  locale_id  (locale_id => locales.id)
#
FactoryBot.define do
  factory :subdomain do
    sequence(:value) { |n| "en#{n}" }
    association :locale

    # Custom trait for hyphenated subdomain linked to English locale
    trait :en_us_hyphenated do
      value { "en-us" }
      association :locale, factory: :locale, key: "en", english_name: "English", name: "English"
    end

    # Trait for www subdomain linked to English locale
    trait :www do
      value { "www" }
      association :locale, factory: :locale, key: "en", english_name: "English", name: "English"
    end

    # Trait for creating custom format subdomains
    trait :custom_format do
      transient do
        subdomain_value { "custom" }
        locale_key { "en" }
        locale_name { "English" }
      end

      value { subdomain_value }
      association :locale, factory: :locale, key: locale_key,
                  english_name: locale_name, name: locale_name
    end
  end
end
