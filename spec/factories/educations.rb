# == Schema Information
#
# Table name: educations
#
#  id             :integer          not null, primary key
#  degree         :string
#  end_year       :integer
#  field_of_study :string
#  school_name    :string           not null
#  start_year     :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  resume_id      :integer          not null
#
# Indexes
#
#  index_educations_on_resume_id  (resume_id)
#
# Foreign Keys
#
#  resume_id  (resume_id => resumes.id)
#
FactoryBot.define do
  factory :education do
    sequence(:school_name) { |n| "University #{n}" }
    degree { "Bachelor of Science" }
    field_of_study { "Computer Science" }
    start_year { rand(1960..Date.current.year) }
    end_year { start_year + 2 }
    association :resume
  end
end
