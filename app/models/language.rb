class Language < ApplicationRecord
  enum :proficiency, [ :elementary, :limited_working, :professional_working, :full_professional, :native_or_bilingual ]

  validates :name, presence: true, uniqueness: true
end
