# == Schema Information
#
# Table name: languages
#
#  id          :integer          not null, primary key
#  name        :string           not null
#  proficiency :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Language < ApplicationRecord
  enum :proficiency, [ :elementary, :limited_working, :professional_working, :full_professional, :native_or_bilingual ]

  validates :name, presence: true, uniqueness: true
end
