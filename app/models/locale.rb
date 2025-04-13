class Locale < ApplicationRecord
  # self.primary_key = :id

  has_many :subdomains, dependent: :restrict_with_exception

  validates :id,
            presence: true,
            uniqueness: true,
            format: {
              with: /\A[a-z][a-z]-*[a-z0-9]*\z/,
              message: "The first two characters are lowercase letters. The rest is empty. If it is not empty, it must start with \"-\""
            }
  validates :english_name, presence: true, uniqueness: true
  validates :name, presence: true, uniqueness: true
end
