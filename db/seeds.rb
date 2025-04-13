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
  github_username
  linkedin_profile_url
  phone_number
  website_url
  blog_url
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
  %w[en English English www],
  %w[zh-CN Chinese 简体中文 cn],
  %w[ar Arabic العربية ar],
  %w[bn Bangla বাংলা bn],
  %w[cs Czech Čeština cz],
  %w[da Danish Dansk dk],
  %w[de-DE German Deutsch de],
  %w[el Greek Ελληνικά gr],
  %w[es-ES Spanish Español es],
  %w[fa Persian فارسی fa],
  %w[fi Finnish Suomi fi],
  %w[fr-FR French Français fr],
  %w[hi Hindi हिंदी hi],
  %w[hu Hungarian Magyar hu],
  [ "id", "Indonesian", "Bahasa Indonesia", "id" ],
  %w[it Italian Italiano it],
  %w[iw-IL Hebrew עברית il],
  %w[ja Japanese 日本語 jp],
  %w[ko Korean 한국어 kr],
  %w[mr-IN Marathi मराठी mr],
  [ "ms", "Malay", "Bahasa Malaysia", "my" ],
  %w[nl Dutch Nederlands nl],
  # %w[no-NO Norwegian Norsk no],
  %w[pa Punjabi ਪੰਜਾਬੀ pa],
  %w[pl Polish Polski pl],
  %w[pt-BR Portuguese Português br],
  %w[ro Romanian Română ro],
  %w[ru Russian Русский ru],
  %w[sv-SE Swedish Svenska se],
  %w[te Telugu తెలుగు te],
  %w[th Thai ภาษาไทย th],
  %w[tl Tagalog Tagalog ph],
  %w[tr Turkish Türkçe tr],
  %w[uk Ukrainian Українська ua],
  %w[vi Vietnamese Tiếng\Việt vn],
  [ "zh-TW", "Traditional Chinese", "正體中文", "tw" ]
].each do |item|
  locale_ = Locale.where(key: item[0]).first_or_create! do |locale|
    locale.english_name = item[1]
    locale.name = item[2]
  end

  Subdomain.where(value: item[3]).first_or_create! do |subdomain|
    subdomain.locale_id = locale_.id
  end
end

puts "Table 'locales' and 'subdomains' data inserted."
