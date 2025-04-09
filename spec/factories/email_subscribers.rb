# == Schema Information
#
# Table name: email_subscribers
#
#  id         :integer          not null, primary key
#  email      :string           not null
#  confirmed  :boolean          default(FALSE)
#  token      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_email_subscribers_on_email  (email) UNIQUE
#
FactoryBot.define do
  factory :email_subscriber do
    sequence(:email) { |n| "subscriber#{n}@example.com" }
    confirmed { false }
    token { nil }

    trait :confirmed do
      confirmed { true }
      token { nil }
    end

    trait :with_token do
      token { SecureRandom.urlsafe_base64(32) }
    end

    trait :pending do
      confirmed { false }
      token { SecureRandom.urlsafe_base64(32) }
    end

    # By default, create with token as the model does
    after(:build) do |subscriber|
      subscriber.token = SecureRandom.urlsafe_base64(32) if subscriber.token.nil? && !subscriber.confirmed
    end
  end
end
