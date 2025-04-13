FactoryBot.define do
  factory :locale do
    sequence(:key) { |n| "xx-#{format('%03d', n)[0..2].upcase}" }
    sequence(:english_name) { |n| "Test Language #{n}" }
    sequence(:name) { |n| "Test Language Value #{n}" }
  end
end
