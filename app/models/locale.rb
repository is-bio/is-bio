# == Schema Information
#
# Table name: locales
#
#  id           :integer          not null, primary key
#  english_name :string           not null
#  key          :string           not null
#  name         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_locales_on_english_name  (english_name) UNIQUE
#  index_locales_on_name          (name) UNIQUE
#
class Locale < ApplicationRecord
  # self.primary_key = :id

  has_many :subdomains, dependent: :restrict_with_exception
  has_many :post_variants
  has_many :posts, through: :post_variants

  validates :key,
            presence: true,
            uniqueness: true,
            format: {
              with: /\A[a-z]{2,3}(-[A-Z0-9]{2,3})?\z/,
              message: "The first two (or three) characters are lowercase letters. The rest is empty. If it is not empty, it must start with \"-\""
            }
  validates :english_name, presence: true, uniqueness: true
  validates :name, presence: true, uniqueness: true

  validate :english_name_and_name_are_unique_across_records

  def self.available_except_current
    available_locale_keys = I18n.available_locales - [ I18n.locale ]
    where(key: available_locale_keys.map(&:to_s))
  end

  private

  def english_name_and_name_are_unique_across_records
    return if english_name.blank? || name.blank?

    if persisted? # not new record
      conflict = Locale.where("name = ? AND id != ?", english_name, id).exists?
    else # new record
      conflict = Locale.where(name: english_name).exists?
    end

    errors.add(:english_name, "has already been used as 'name' in another record") if conflict

    if persisted?
      conflict = Locale.where("english_name = ? AND id != ?", name, id).exists?
    else
      conflict = Locale.where(english_name: name).exists?
    end

    errors.add(:name, "has already been used as 'english_name' in another record") if conflict
  end
end
