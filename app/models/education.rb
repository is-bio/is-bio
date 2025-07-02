# == Schema Information
#
# Table name: educations
#
#  id             :integer          not null, primary key
#  degree         :string
#  end_year       :integer
#  field_of_study :string
#  school_name    :string           not null
#  start_year     :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  resume_id      :integer          not null
#
# Indexes
#
#  index_educations_on_resume_id  (resume_id)
#
# Foreign Keys
#
#  resume_id  (resume_id => resumes.id)
#
class Education < ApplicationRecord
  MAX_YEAR = Date.current.year + 8
  MIN_YEAR = 1960

  belongs_to :resume

  validates :school_name, presence: true
  validates :start_year, :end_year,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: MIN_YEAR,
              less_than_or_equal_to: MAX_YEAR,
              message: "must be between #{MIN_YEAR} and #{MAX_YEAR}"
            }
  validate :end_year_not_earlier_than_start

  before_validation :cleanup_fields

  private

  def cleanup_fields
    if degree == ""
      self.degree = nil
    end

    if field_of_study == ""
      self.field_of_study = nil
    end
  end

  def end_year_not_earlier_than_start
    return if start_year.blank? || end_year.blank?

    if end_year < start_year
      errors.add(:end_year, "can't be earlier than start year")
    end
  end
end
