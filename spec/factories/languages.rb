# == Schema Information
#
# Table name: languages
#
#  id          :integer          not null, primary key
#  name        :string           not null
#  proficiency :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  resume_id   :integer          not null
#
# Indexes
#
#  index_languages_on_resume_id  (resume_id)
#
# Foreign Keys
#
#  resume_id  (resume_id => resumes.id)
#
FactoryBot.define do
  factory :language do
    name { "Spanish" }
    proficiency { :professional_working }
    association :resume
  end
end
