# Uncomment the bellow code to create the administrator user.
# email = "change_to_your_email@example.com"
# password = "ChangeToYourPassword_ChangeToYourPassword_ChangeToYourPassword_ChangeToYourPassword"
# User.where(
#   email_address: email
# ).first_or_create! do |user|
#   user.password = password
#   user.password_confirmation = password
# end
# puts "The administrator user '#{email}' was created successfully. You can use this email to log in."

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

%w[
  app_id
  public_link
].each_with_index do |key, i|
  GithubAppSetting.where(id: i + 1, key: key).first_or_create!
end
puts "Table 'github_app_settings' data inserted."

%w[
  github_username
].each_with_index do |key, i|
  Setting.where(id: i + 1, key: key).first_or_create!
end
puts "Table 'settings' data inserted."

%w[
  email
  phone_number
  website_url
  blog_url
  github_username
  linkedin_profile_url
  wechat_id
  x_username
  tiktok_username
  youtube_channel_handle
  facebook_username
  instagram_username
  messenger_username
  whatsapp_account
  telegram_username
  snapchat_username
  pinterest_username
  threads_username
  stackoverflow_profile_url
  leetcode_profile_url
  quora_profile_url
  qq
  douyin_identifier
  kuaishou_profile_url
  weixin_mp_name
  weibo_nickname
  weibo_profile_id
  zhihu_profile_url
  line_id
  kakaotalk_id
].each_with_index do |key, i|
  SocialMediaAccount.where(id: i + 1, key: key).first_or_create!
end
puts "Table 'social_media_accounts' data inserted."

Category.where(id: Category::ID_PUBLISHED).first_or_create! do |category|
  category.name = "published"
end

Category.where(id: Category::ID_DRAFTS).first_or_create! do |category|
  category.name = "drafts"
end
puts "Table 'categories' data inserted."

[
  %w[en English English],
  %w[zh Chinese 简体中文],
  %w[ar Arabic العربية],
  %w[bn Bangla বাংলা],
  %w[cs Czech Čeština],
  %w[da Danish Dansk],
  %w[de German Deutsch],
  %w[el Greek Ελληνικά],
  %w[es Spanish Español],
  %w[fa Persian فارسی],
  %w[fi Finnish Suomi],
  %w[fr French Français],
  %w[hi Hindi हिंदी],
  %w[hu Hungarian Magyar],
  [ "id", "Indonesian", "Bahasa Indonesia" ],
  %w[it Italian Italiano],
  %w[iw Hebrew עברית],
  %w[ja Japanese 日本語],
  %w[ko Korean 한국어],
  %w[mr Marathi मराठी],
  [ "ms", "Malay", "Bahasa Malaysia" ],
  %w[nl Dutch Nederlands],
  %w[pa Punjabi ਪੰਜਾਬੀ],
  %w[pl Polish Polski],
  %w[pt Portuguese Português],
  %w[ro Romanian Română],
  %w[ru Russian Русский],
  %w[sv Swedish Svenska],
  %w[te Telugu తెలుగు],
  %w[th Thai ภาษาไทย],
  %w[tl Tagalog Tagalog],
  %w[tr Turkish Türkçe],
  %w[uk Ukrainian Українська],
  [ "vi", "Vietnamese", "Tiếng Việt" ],
  [ "zh-TW", "Traditional Chinese", "正體中文" ]
  # %w[no-NO Norwegian Norsk],
].each do |item|
  Locale.where(key: item[0]).first_or_create! do |locale|
    locale.english_name = item[1]
    locale.name = item[2]
  end
end

puts "Table 'locales' data inserted."

Theme.where(id: 1).first_or_create! do |theme|
  theme.name = "DevBlog"
  theme.free = true
  theme.enabled = true
  theme.color = 1
end

puts "Table 'themes' data inserted."
