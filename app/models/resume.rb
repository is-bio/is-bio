# == Schema Information
#
# Table name: resumes
#
#  id            :integer          not null, primary key
#  birth_date    :date
#  city          :string
#  email_address :string           not null
#  height        :integer
#  name          :string           not null
#  phone_number  :string
#  position      :string
#  summary       :string
#  title         :string           not null
#  weight        :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class Resume < ApplicationRecord
  validates :title, :name, :email_address, :position, :city, :summary, presence: true
  validates :email_address, format: { with: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i, message: "is not a valid email format" }
  validates :phone_number, format: { with: /\A\+?[\d\s\-\(\)]+\z/, message: "is not a valid phone number format" }, allow_blank: true
  validate :validate_birth_date

  private

  def validate_birth_date
    if birth_date.present?
      begin
        Date.parse(birth_date.to_s)
      rescue Exception

        errors.add(:birth_date, "is not a valid date")
      end
    end
  end
end
