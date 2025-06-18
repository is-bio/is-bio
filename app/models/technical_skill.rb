# == Schema Information
#
# Table name: technical_skills
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class TechnicalSkill < ApplicationRecord
  validates :name, presence: true, uniqueness: true
end
