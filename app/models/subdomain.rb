# == Schema Information
#
# Table name: subdomains
#
#  id         :integer          not null, primary key
#  value      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  locale_id  :integer          not null
#
# Indexes
#
#  index_subdomains_on_locale_id  (locale_id)
#  index_subdomains_on_value      (value) UNIQUE
#
# Foreign Keys
#
#  locale_id  (locale_id => locales.id)
#
class Subdomain < ApplicationRecord
  belongs_to :locale

  validates :value, presence: true,
                    uniqueness: true,
                    format: {
                      with: /\A[a-z0-9][a-z0-9-]*[a-z0-9]\z/,
                      message: "Can only contain lowercase letters, numbers, and hyphens, and cannot start or end with a hyphen"
                    }
end
