# == Schema Information
#
# Table name: settings
#
#  id         :integer          not null, primary key
#  key        :string           not null
#  value      :string
#  updated_at :datetime
#
# Indexes
#
#  index_settings_on_key  (key) UNIQUE
#
class Setting < ApplicationRecord
  validates :key, presence: true, uniqueness: true, format: { with: /\A[a-z_0-9]+\z/, message: 'is invalid! Only lowercase letters, numbers and "_" are valid characters.' }

  validate :value_valid?

  before_validation :cleanup_value
  before_save :set_nil

  def target_url?
    target_url(true).present?
  end

  def target_url_base
    target_url(true)
  end

private

  # noinspection RubyNilAnalysis
  def cleanup_value
    return if value.nil?

    self.value.strip!
  end

  def set_nil
    if value.blank?
      self.value = nil
    end
  end

  def value_valid?
    if value.blank?
      return
    end

    if key == "github_username"
      unless /\A[a-zA-Z0-9\-]+\z/.match?(value)
        errors.add :value, 'is invalid! Only letters, numbers and "-" are valid characters.'
      end
    end
  end

  def target_url(only_url_base = false)
    value = only_url_base ? nil : self.value

    case key
    when "github_username"
      "https://github.com/#{value}"
    else
      nil
    end
  end
end
