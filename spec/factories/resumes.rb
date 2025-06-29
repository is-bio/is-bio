# == Schema Information
#
# Table name: resumes
#
#  id            :integer          not null, primary key
#  birth_date    :date
#  city          :string
#  email_address :string           not null
#  height        :integer
#  name          :string           not null
#  phone_number  :string
#  position      :string
#  summary       :text
#  title         :string           not null
#  weight        :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
FactoryBot.define do
  factory :resume do
    sequence(:title) { |n| "Resume #{n}" }
    name { "John Doe" }
    sequence(:email_address) { |n| "john.doe#{n}@example.com" }
    phone_number { "+1 (555) 123-4567" }
    position { "Ruby Developer" }
    city { "New York" }
    summary { "I am a good developer." }
    birth_date { Date.new(1990, 1, 15) }
    height { 175 }
    weight { 68 }
  end
end
