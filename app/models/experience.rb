# == Schema Information
#
# Table name: experiences
#
#  id           :integer          not null, primary key
#  company_name :string           not null
#  description  :text
#  end_month    :integer
#  end_year     :integer
#  start_month  :integer
#  start_year   :integer
#  title        :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  resume_id    :integer          not null
#
# Indexes
#
#  index_experiences_on_resume_id  (resume_id)
#
# Foreign Keys
#
#  resume_id  (resume_id => resumes.id)
#
class Experience < ApplicationRecord
  MAX_YEAR = Date.current.year + 8
  MIN_YEAR = 1960

  belongs_to :resume

  validates :company_name, presence: true
  validates :title, presence: true
  validates :description, presence: true
  validates :start_year, presence: true
  validates :start_year, :end_year,
            allow_blank: true,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: MIN_YEAR,
              less_than_or_equal_to: MAX_YEAR,
              message: "must be between #{MIN_YEAR} and #{MAX_YEAR}"
            }
  validate :end_month_not_earlier_than_start_month
  validates :start_month, :end_month,
            allow_blank: true,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 1,
              less_than_or_equal_to: 12
            }

  private

  def end_month_not_earlier_than_start_month
    return if end_year.blank?

    if end_year < start_year
      errors.add(:end_year, "can't be earlier than start year")
    end

    if end_year == start_year
      if start_month.present? && end_month.present?
        if start_month > end_month
          errors.add(:end_month, "can't be earlier than start month")
        end
      end
    end
  end
end
