# == Schema Information
#
# Table name: projects
#
#  id           :integer          not null, primary key
#  description  :text             not null
#  name         :string           not null
#  summary      :text             not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  resume_id    :integer          not null
#
# Indexes
#
#  index_projects_on_resume_id  (resume_id)
#
# Foreign Keys
#
#  resume_id  (resume_id => resumes.id)
#
FactoryBot.define do
  factory :project do
    name { Faker::App.name }
    summary { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    association :resume
  end
end
