# == Schema Information
#
# Table name: subdomains
#
#  value      :string           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  locale_id  :integer          not null
#
# Indexes
#
#  index_subdomains_on_locale_id  (locale_id)
#
# Foreign Keys
#
#  locale_id  (locale_id => locales.id)
#
FactoryBot.define do
  factory :subdomain do
    sequence(:value) { |n| "en#{n}" }
    association :locale
  end
end 
