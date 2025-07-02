# == Schema Information
#
# Table name: interests
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  resume_id  :integer          not null
#
# Indexes
#
#  index_interests_on_resume_id  (resume_id)
#
# Foreign Keys
#
#  resume_id  (resume_id => resumes.id)
#
class Interest < ApplicationRecord
  belongs_to :resume

  validates :name, presence: true, uniqueness: true
end
