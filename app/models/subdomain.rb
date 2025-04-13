# == Schema Information
#
# Table name: subdomains
#
#  value      :string           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  locale_id  :integer          not null
#
# Indexes
#
#  index_subdomains_on_locale_id  (locale_id)
#
# Foreign Keys
#
#  locale_id  (locale_id => locales.id)
#
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
