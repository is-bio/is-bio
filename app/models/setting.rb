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

  private

    def value_valid?
      if value.blank?
        return
      end

      if key == "email"
        unless URI::MailTo::EMAIL_REGEXP.match?(value)
          errors.add :value, "is invalid! Please enter a valid email address."
        end
      end

      if key == "phone_number"
        unless /\A[0-9+\- ()*#]+\z/.match?(value)
          errors.add :value, "is invalid! Please enter a valid phone number."
        end
      end

      if %w[website_url blog_url linkedin_profile_url stackoverflow_profile_url leetcode_profile_url quora_profile_url kuaishou_profile_url zhihu_profile_url].include?(key)
        unless URI::DEFAULT_PARSER.make_regexp(%w[http https]).match?(value)
          errors.add :value, "is invalid! Please enter a valid #{key.titleize}."
        end
      end

      if %w[qq weibo_profile_id].include?(key)
        unless value.to_i.to_s == value
          errors.add :value, "is invalid! Please enter an integer!"
        end
      end

      if key == "github_username"
        unless /\A[a-zA-Z0-9\-]+\z/.match?(value)
          errors.add :value, 'is invalid! Only letters, numbers and "-" are valid characters.'
        end
      end

      if %w[wechat_id x_username tiktok_username youtube_channel_handle instagram_username facebook_username messenger_username whatsapp_account telegram_username threads_username snapchat_username douyin_identifier line_id kakaotalk_id].include?(key)
        unless /\A[a-zA-Z0-9._\-]+\z/.match?(value)
          errors.add :value, "is invalid!"
        end
      end
    end
end
