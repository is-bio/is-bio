# == Schema Information
#
# Table name: technical_skills
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  resume_id  :integer          not null
#
# Indexes
#
#  index_technical_skills_on_resume_id  (resume_id)
#
# Foreign Keys
#
#  resume_id  (resume_id => resumes.id)
#
class TechnicalSkill < ApplicationRecord
  validates :name, presence: true, uniqueness: true
end
