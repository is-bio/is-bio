# == Schema Information
#
# Table name: professional_skills
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class ProfessionalSkill < ApplicationRecord
  validates :name, presence: true, uniqueness: true
end
