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
require "rails_helper"

RSpec.describe Setting, type: :model do
  before(:each) do
    Setting.delete_all
  end

  describe "validations" do
    context "key validations" do
      it "requires key presence" do
        setting = build(:setting, key: nil)
        expect(setting).not_to be_valid
        expect(setting.errors[:key]).to include("can't be blank")
      end

      it "requires unique keys" do
        create(:setting, key: "unique_test_key")
        setting = build(:setting, key: "unique_test_key")
        expect(setting).not_to be_valid
        expect(setting.errors[:key]).to include("has already been taken")
      end

      it "validates key format" do
        valid_keys = %w[test_key_1 key123_2 valid_key_123_3]
        invalid_keys = ["Test-Key", "invalid key", "UPPERCASE", "special!char"]

        valid_keys.each do |key|
          setting = build(:setting, key: key)
          expect(setting).to be_valid
        end

        invalid_keys.each do |key|
          setting = build(:setting, key: key)
          expect(setting).not_to be_valid
          expect(setting.errors[:key]).to include('is invalid! Only lowercase letters, numbers and "_" are valid characters.')
        end
      end
    end

    context "value validations" do
      context "github_username validation" do
        it "accepts valid github usernames" do
          setting = build(:setting, key: "github_username", value: "user-name")
          expect(setting).to be_valid
        end

        it "rejects invalid github usernames" do
          setting = build(:setting, key: "github_username", value: "user_name")
          expect(setting).not_to be_valid
          expect(setting.errors[:value]).to include('is invalid! Only letters, numbers and "-" are valid characters.')
        end
      end

      it "allows blank values" do
        setting = build(:setting, :empty_value)
        expect(setting).to be_valid
      end
    end
  end

  describe "callbacks" do
    describe "#cleanup_value" do
      it "trims whitespace from the value" do
        setting = build(:setting, key: "cleanup_test", value: "  example  ")
        setting.valid?
        expect(setting.value).to eq("example")
      end

      it "doesn't modify nil values" do
        setting = build(:setting, key: "nil_test", value: nil)
        setting.valid?
        expect(setting.value).to be_nil
      end
    end

    describe "#set_nil" do
      it "converts empty strings to nil" do
        setting = create(:setting, key: "empty_string_test", value: "")
        expect(setting.reload.value).to be_nil
      end

      it "converts whitespace-only strings to nil" do
        setting = create(:setting, key: "whitespace_test", value: "   ")
        expect(setting.reload.value).to be_nil
      end

      it "leaves non-blank values unchanged" do
        setting = create(:setting, key: "non_blank_test", value: "example")
        expect(setting.reload.value).to eq("example")
      end
    end
  end

  describe "instance methods" do
    describe "#target_url?" do
      it "returns true for github_username key" do
        setting = build(:setting, :github_username)
        expect(setting.target_url?).to be true
      end

      it "returns false for other keys" do
        setting = build(:setting)
        expect(setting.target_url?).to be false
      end
    end

    describe "#target_url_base" do
      it "returns the GitHub base URL for github_username" do
        setting = build(:setting, :github_username)
        expect(setting.target_url_base).to eq("https://github.com/")
      end

      it "returns nil for other keys" do
        setting = build(:setting)
        expect(setting.target_url_base).to be_nil
      end
    end
  end
end
