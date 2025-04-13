FactoryBot.define do
  factory :locale do
    sequence(:key) { |n| "en-#{n}" }
    sequence(:english_name) { |n| "English #{n}" }
    sequence(:name) { |n| "English #{n}" }
  end
end
