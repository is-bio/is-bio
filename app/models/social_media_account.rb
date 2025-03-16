# == Schema Information
#
# Table name: social_media_accounts
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
class SocialMediaAccount < ApplicationRecord
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

  def compatible_target_url
    if target_url.present?
      return target_url
    end

    if (value || "").start_with?("http")
      value
    end
  end

  def target_url(only_url_base = false)
    value = only_url_base ? nil : self.value

    case key
    when "github_username"
      "https://github.com/#{value}"
    when "x_username"
      "https://x.com/#{value}"
    when "tiktok_username"
      "https://www.tiktok.com/@#{value}"
    when "youtube_channel_handle"
      "https://www.youtube.com/@#{value}"
    when "facebook_username"
      "https://www.facebook.com/#{value}"
    when "instagram_username"
      "https://www.instagram.com/#{value}"
    when "pinterest_username"
      "https://www.pinterest.com/#{value}"
    when "threads_username"
      "https://www.threads.net/@#{value}"
    when "telegram_username"
      "https://t.me/#{value}"
    when "snapchat_username"
      "https://www.snapchat.com/add/#{value}"
    when "weibo_profile_id"
      "https://weibo.com/u/#{value}"
    else
      nil
    end
  end

  def target_url_example
    case key
    when "linkedin_profile_url"
      "https://www.linkedin.com/in/jane-doe/"
    when "stackoverflow_profile_url"
      "https://stackoverflow.com/users/2566738/john-doe"
    when "kuaishou_profile_url"
      "https://www.kuaishou.com/profile/3xx447u7m69aztg"
    when "leetcode_profile_url"
      "https://leetcode.com/u/johndoe/"
    when "quora_profile_url"
      "https://www.quora.com/profile/John-Doe"
    when "zhihu_profile_url"
      "https://www.zhihu.com/people/jane-doe"
    else
      nil
    end
  end

  def icon_name
    case key
    when "email"
      "fa fa-envelope"
    when "phone_number"
      "fa fa-phone"
    when "website_url"
      "fa fa-link"
    when "blog_url"
      "fa fa-link"
    when "linkedin_profile_url"
      "fab fa-linkedin-in"
    when "stackoverflow_profile_url"
      "fab fa-stack-overflow"
    when "leetcode_profile_url"
      "fa fa-code" # not correct
    when "quora_profile_url"
      "fab fa-quora"
    when "kuaishou_profile_url"
      "fa fa-video-camera" # not correct
    when "zhihu_profile_url"
      "fa fa-question"
    when "qq"
      "fab fa-qq"
    when "weibo_profile_id"
      "fab fa-weibo"
    when "weibo_nickname"
      "fab fa-weibo"
    when "github_username"
      "fab fa-github"
    when "wechat_id"
      "fab fa-weixin"
    when "weixin_mp_name"
      "fab fa-weixin"
    when "x_username"
      "fab fa-twitter"
    when "tiktok_username"
      "fa fa-video-camera" # not correct
    when "youtube_channel_handle"
      "fab fa-youtube"
    when "instagram_username"
      "fab fa-instagram"
    when "facebook_username"
      "fab fa-facebook"
    when "messenger_username"
      "fab fa-whatsapp" # not correct
    when "whatsapp_account"
      "fab fa-whatsapp"
    when "telegram_username"
      "fab fa-telegram"
    when "snapchat_username"
      "fab fa-snapchat"
    when "pinterest_username"
      "fab fa-pinterest"
    when "threads_username"
      "fa fa-mars-double" # not correct
    when "douyin_identifier"
      "fa fa-video-camera" # not correct
    when "line_id"
      "fab fa-whatsapp" # not correct
    when "kakaotalk_id"
      "fab fa-whatsapp" # not correct
    else
      "fab fa-link"
    end
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

    if %w[wechat_id x_username tiktok_username youtube_channel_handle instagram_username facebook_username messenger_username whatsapp_account telegram_username threads_username snapchat_username douyin_identifier pinterest_username line_id kakaotalk_id].include?(key)
      unless /\A[a-zA-Z0-9._\-]+\z/.match?(value)
        errors.add :value, "is invalid!"
      end
    end
  end
end
