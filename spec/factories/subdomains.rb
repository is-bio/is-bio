FactoryBot.define do
  factory :subdomain do
    sequence(:value) { |n| "en#{n}" }
    association :locale
  end
end 