# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

email = "change_to_your_email@example.com"
password = "ChangeToYourPassword_ChangeToYourPassword_ChangeToYourPassword_ChangeToYourPassword"
User.where(
  email_address: email
).first_or_create! do |user|
  user.password = password
  user.password_confirmation = password
end
puts "The administrator user '#{email}' was created successfully. You can use this email to log in."

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
  instagram_username
  facebook_username
  messenger_username
  whatsapp_account
  telegram_username
  threads_username
  snapchat_username
  stackoverflow_profile_url
  quora_profile_url
  qq
  douyin_identifier
  kuaishou_profile_url
  weibo_profile_id
  zhihu_profile_url
  line_id
  kakaotalk_id
].each_with_index do |key, i|
  Setting.where(id: i + 1, key: key).first_or_create!
end
puts "Table 'settings' data inserted."

Category.where(id: Category::PUBLISHED_ID).first_or_create! do |category|
  category.name = "published"
end

Category.where(id: Category::DRAFTS_ID).first_or_create! do |category|
  category.name = "drafts"
end
puts "Table 'categories' data inserted."
