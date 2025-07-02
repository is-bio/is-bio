# == Schema Information
#
# Table name: professional_skills
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  resume_id  :integer          not null
#
# Indexes
#
#  index_professional_skills_on_resume_id  (resume_id)
#
# Foreign Keys
#
#  resume_id  (resume_id => resumes.id)
#
class ProfessionalSkill < ApplicationRecord
  belongs_to :resume

  validates :name, presence: true, uniqueness: true
end
