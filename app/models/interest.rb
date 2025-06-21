# == Schema Information
#
# Table name: interests
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Interest < ApplicationRecord
  validates :name, presence: true, uniqueness: true
end
