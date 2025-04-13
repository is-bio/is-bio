class Locale < ApplicationRecord
  # self.primary_key = :id

  has_many :subdomains, dependent: :restrict_with_exception

  validates :key,
            presence: true,
            uniqueness: true,
            format: {
              with: /\A[a-z]{2}(-[A-Z0-9]{2,3})?\z/,
              message: "The first two characters are lowercase letters. The rest is empty. If it is not empty, it must start with \"-\""
            }
  validates :english_name, presence: true, uniqueness: { scope: :name, message: "and name combination must be unique" }
  validates :name, presence: true, uniqueness: { scope: :english_name, message: "and english_name combination must be unique" }
end
