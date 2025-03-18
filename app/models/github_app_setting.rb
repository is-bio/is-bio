# == Schema Information
#
# Table name: github_app_settings
#
#  id         :integer          not null, primary key
#  key        :string           not null
#  value      :string
#  updated_at :datetime
#
# Indexes
#
#  index_github_app_settings_on_key  (key) UNIQUE
#
class GithubAppSetting < ApplicationRecord
  validates :key, presence: true, uniqueness: true, format: { with: /\A[a-z_0-9]+\z/, message: 'is invalid! Only lowercase letters, numbers and "_" are valid characters.' }
  validate :value_valid?, on: :update

  before_validation :cleanup_value

  private

  def value_valid?
    if key == "app_id"
      unless value.to_i.to_s == value
        errors.add :value, "must be an integer!"
      end
    end

    if key == "public_link"
      unless value.blank? || URI::DEFAULT_PARSER.make_regexp(%w[http https]).match?(value)
        errors.add :value, "is invalid! Please enter a valid #{key.titleize} URL."
      end
    end
  end

  # noinspection RubyNilAnalysis
  def cleanup_value
    return if value.nil?

    self.value.strip!
  end
end
