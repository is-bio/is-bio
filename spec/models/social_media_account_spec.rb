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
#  index_social_media_accounts_on_key  (key) UNIQUE
#
require "rails_helper"

RSpec.describe SocialMediaAccount, type: :model do
  before(:each) do
    SocialMediaAccount.delete_all
  end

  describe "validations" do
    context "key validations" do
      it "requires key presence" do
        account = build(:social_media_account, key: nil)
        expect(account).not_to be_valid
        expect(account.errors[:key]).to include("can't be blank")
      end

      it "requires unique keys" do
        create(:social_media_account, key: "test_key")
        account = build(:social_media_account, key: "test_key")
        expect(account).not_to be_valid
        expect(account.errors[:key]).to include("has already been taken")
      end

      it "validates key format" do
        valid_keys = %w[ test_key key123 valid_key_123 ]
        invalid_keys = [ "Test-Key", "invalid key", "UPPERCASE", "special!char" ]

        valid_keys.each do |key|
          account = build(:social_media_account, key: key)
          expect(account).to be_valid
        end

        invalid_keys.each do |key|
          account = build(:social_media_account, key: key)
          expect(account).not_to be_valid
          expect(account.errors[:key]).to include('is invalid! Only lowercase letters, numbers and "_" are valid characters.')
        end
      end
    end

    context "value validations" do
      context "email validation" do
        let(:account) { build(:social_media_account, key: "email") }

        it "accepts valid email addresses" do
          valid_emails = %w[ user1493@example.com firstname.lastname@example.co.uk user+tag@domain.com ]

          valid_emails.each do |email|
            account.value = email
            expect(account).to be_valid
          end
        end

        it "rejects invalid email addresses" do
          invalid_emails = %w[ invalid-email user@ @domain.com ]

          invalid_emails.each do |email|
            account.value = email
            expect(account).not_to be_valid
            expect(account.errors[:value]).to include("is invalid! Please enter a valid email address.")
          end
        end
      end

      context "phone number validation" do
        let(:account) { build(:social_media_account, key: "phone_number") }

        it "accepts valid phone numbers" do
          valid_numbers = [ "+1 123-456-7890", "123-456-7890", "+86 13812345678", "555-555-5555", "(123) 456-7890" ]

          valid_numbers.each do |number|
            account.value = number
            expect(account).to be_valid
          end
        end

        it "rejects invalid phone numbers" do
          invalid_numbers = [ "phone number", "abc-def-ghij", "123.456.7890" ]

          invalid_numbers.each do |number|
            account.value = number
            expect(account).not_to be_valid
            expect(account.errors[:value]).to include("is invalid! Please enter a valid phone number.")
          end
        end
      end

      context "URL validation" do
        %w[ website_url blog_url linkedin_profile_url stackoverflow_profile_url leetcode_profile_url quora_profile_url kuaishou_profile_url zhihu_profile_url ].each do |url_type|
          context "for #{url_type}" do
            let(:account) { build(:social_media_account, key: url_type) }

            it "accepts valid URLs" do
              valid_urls = [ "https://example.com", "http://example.org/path", "https://sub.domain.co.uk/page?param=value" ]

              valid_urls.each do |url|
                account.value = url
                expect(account).to be_valid
              end
            end

            it "rejects invalid URLs" do
              invalid_urls = [ "example.com", "www.example.com", "not_a_url" ]

              invalid_urls.each do |url|
                account.value = url
                expect(account).not_to be_valid
                expect(account.errors[:value]).to include("is invalid! Please enter a valid #{url_type.titleize}.")
              end
            end
          end
        end
      end

      context "numeric validation" do
        %w[ qq weibo_profile_id ].each do |numeric_type|
          context "for #{numeric_type}" do
            let(:account) { build(:social_media_account, key: numeric_type) }

            it "accepts valid numeric values" do
              valid_numbers = [ "123456", "987654321" ]

              valid_numbers.each do |number|
                account.value = number
                expect(account).to be_valid
              end
            end

            it "rejects non-numeric values" do
              invalid_numbers = [ "123abc", "12.34", "not-a-number" ]

              invalid_numbers.each do |number|
                account.value = number
                expect(account).not_to be_valid
                expect(account.errors[:value]).to include("is invalid! Please enter an integer!")
              end
            end
          end
        end
      end

      context "username format validation" do
        context "for github_username" do
          let(:account) { build(:social_media_account, key: "github_username") }

          it "accepts valid github usernames" do
            valid_usernames = [ "user", "user-name", "user123" ]

            valid_usernames.each do |username|
              account.value = username
              expect(account).to be_valid
            end
          end

          it "rejects invalid github usernames" do
            invalid_usernames = [ "user_name", "User Name", "user@name" ]

            invalid_usernames.each do |username|
              account.value = username
              expect(account).not_to be_valid
              expect(account.errors[:value]).to include('is invalid! Only letters, numbers and "-" are valid characters.')
            end
          end
        end

        %w[ x_username tiktok_username youtube_channel_handle instagram_username facebook_username ].each do |username_type|
          context "for #{username_type}" do
            let(:account) { build(:social_media_account, key: username_type) }

            it "accepts valid usernames" do
              valid_usernames = [ "user", "user_name", "user.name", "user123", "user-name" ]

              valid_usernames.each do |username|
                account.value = username
                expect(account).to be_valid
              end
            end

            it "rejects invalid usernames" do
              invalid_usernames = [ "user name", "user@name", "user#name" ]

              invalid_usernames.each do |username|
                account.value = username
                expect(account).not_to be_valid
                expect(account.errors[:value]).to include("is invalid!")
              end
            end
          end
        end
      end
    end
  end

  describe "instance methods" do
    describe "#target_url?" do
      it "returns true when target_url is present" do
        account = build(:social_media_account, key: "github_username", value: "octocat")
        expect(account.target_url?).to be_truthy
      end

      it "returns false when target_url is not present" do
        account = build(:social_media_account, key: "email", value: "user@example.com")
        expect(account.target_url?).to be_falsey
      end
    end

    describe "#target_url_base" do
      it "returns the base URL for supported platforms" do
        account = build(:social_media_account, key: "github_username")
        expect(account.target_url_base).to eq("https://github.com/")
      end

      it "returns nil for unsupported platforms" do
        account = build(:social_media_account, key: "email")
        expect(account.target_url_base).to be_nil
      end
    end

    describe "#target_url" do
      context "with GitHub username" do
        it "returns the GitHub profile URL" do
          account = build(:social_media_account, key: "github_username", value: "octocat")
          expect(account.target_url).to eq("https://github.com/octocat")
        end
      end

      context "with X (Twitter) username" do
        it "returns the X profile URL" do
          account = build(:social_media_account, key: "x_username", value: "twitter")
          expect(account.target_url).to eq("https://x.com/twitter")
        end
      end

      context "with unsupported key" do
        it "returns nil" do
          account = build(:social_media_account, key: "email", value: "user@example.com")
          expect(account.target_url).to be_nil
        end
      end
    end

    describe "#compatible_target_url" do
      context "when target_url is present" do
        it "returns the target_url" do
          account = build(:social_media_account, key: "github_username", value: "octocat")
          expect(account.compatible_target_url).to eq("https://github.com/octocat")
        end
      end

      context "when value starts with http" do
        it "returns the value" do
          account = build(:social_media_account, key: "website_url", value: "https://example.com")
          expect(account.compatible_target_url).to eq("https://example.com")
        end
      end

      context "when neither condition is met" do
        it "returns nil" do
          account = build(:social_media_account, key: "email", value: "user@example.com")
          expect(account.compatible_target_url).to be_nil
        end
      end
    end

    describe "#target_url_example" do
      it "returns example URLs for supported keys" do
        examples = {
          "linkedin_profile_url" => "https://www.linkedin.com/in/jane-doe/",
          "stackoverflow_profile_url" => "https://stackoverflow.com/users/2566738/john-doe",
          "kuaishou_profile_url" => "https://www.kuaishou.com/profile/3xx447u7m69aztg"
        }

        examples.each do |key, expected_url|
          account = build(:social_media_account, key: key)
          expect(account.target_url_example).to eq(expected_url)
        end
      end

      it "returns nil for unsupported keys" do
        account = build(:social_media_account, key: "unsupported_key")
        expect(account.target_url_example).to be_nil
      end
    end

    describe "#icon_name" do
      it "returns the correct icon names for different account types" do
        icon_mappings = {
          "email" => "fa fa-envelope",
          "phone_number" => "fa fa-phone",
          "website_url" => "fa fa-link",
          "github_username" => "fab fa-github",
          "x_username" => "fab fa-twitter",
          "linkedin_profile_url" => "fab fa-linkedin-in"
        }

        icon_mappings.each do |key, expected_icon|
          account = build(:social_media_account, key: key)
          expect(account.icon_name).to eq(expected_icon)
        end
      end

      it "returns default icon for unknown keys" do
        account = build(:social_media_account, key: "unknown_key")
        expect(account.icon_name).to eq("fab fa-link")
      end
    end
  end

  describe "callbacks" do
    describe "#cleanup_value" do
      it "trims whitespace from the value" do
        account = build(:social_media_account, value: "  example  ")
        account.valid?
        expect(account.value).to eq("example")
      end

      it "doesn't modify nil values" do
        account = build(:social_media_account, value: nil)
        account.valid?
        expect(account.value).to be_nil
      end
    end

    describe "#set_nil" do
      it "converts empty strings to nil" do
        account = create(:social_media_account, key: "email", value: "")
        expect(account.reload.value).to be_nil
      end

      it "converts whitespace-only strings to nil" do
        account = create(:social_media_account, key: "email", value: "   ")
        expect(account.reload.value).to be_nil
      end

      it "leaves non-blank values unchanged" do
        account = create(:social_media_account, key: "email", value: "example@example.com")
        expect(account.reload.value).to eq("example@example.com")
      end
    end
  end
end
