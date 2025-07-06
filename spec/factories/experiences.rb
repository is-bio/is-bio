# == Schema Information
#
# Table name: experiences
#
#  id           :integer          not null, primary key
#  company_name :string           not null
#  description  :text             not null
#  end_month    :integer
#  end_year     :integer
#  start_month  :integer
#  start_year   :integer          not null
#  title        :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  resume_id    :integer          not null
#
# Indexes
#
#  index_experiences_on_resume_id  (resume_id)
#
# Foreign Keys
#
#  resume_id  (resume_id => resumes.id)
#
FactoryBot.define do
  factory :experience do
    company_name { Faker::Company.name }
    title { Faker::Job.title }
    description { Faker::Lorem.paragraph }
    start_year { rand(Experience::MIN_YEAR..Experience::MAX_YEAR - 5) }
    start_month { rand(1..12) }
    end_year { start_year + rand(1..5) }
    association :resume
  end
end
