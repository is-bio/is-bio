class Subdomain < ApplicationRecord
  self.primary_key = :value

  belongs_to :locale

  validates :value, presence: true,
                    uniqueness: true,
                    format: {
                      with: /\A[a-z0-9][a-z0-9-]*[a-z0-9]\z/,
                      message: "Can only contain lowercase letters, numbers, and hyphens, and cannot start or end with a hyphen"
                    }
end
