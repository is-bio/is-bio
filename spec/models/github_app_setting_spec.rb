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
require "rails_helper"

RSpec.describe GithubAppSetting, type: :model do
  before(:each) do
    GithubAppSetting.delete_all
  end

  describe "validations" do
    context "key validations" do
      it "requires key presence" do
        app_setting = build(:github_app_setting, key: nil)
        expect(app_setting).not_to be_valid
        expect(app_setting.errors[:key]).to include("can't be blank")
      end

      it "requires unique keys" do
        create(:github_app_setting, key: "unique_test_key")
        app_setting = build(:github_app_setting, key: "unique_test_key")
        expect(app_setting).not_to be_valid
        expect(app_setting.errors[:key]).to include("has already been taken")
      end

      it "validates key format" do
        valid_keys = %w[test_key_1 key123_2 valid_key_123_3]
        invalid_keys = [ "Test-Key", "invalid key", "UPPERCASE", "special!char" ]

        valid_keys.each do |key|
          app_setting = build(:github_app_setting, key: key)
          expect(app_setting).to be_valid
        end

        invalid_keys.each do |key|
          app_setting = build(:github_app_setting, key: key)
          expect(app_setting).not_to be_valid
          expect(app_setting.errors[:key]).to include('is invalid! Only lowercase letters, numbers and "_" are valid characters.')
        end
      end
    end

    context "value validations" do
      context "app_id validation" do
        it "accepts valid integer values" do
          app_setting = create(:github_app_setting, key: "app_id")
          app_setting.value = "12345"
          app_setting.validate # Trigger validation manually since we're testing on update
          expect(app_setting).to be_valid
        end

        it "rejects non-integer value" do
          app_setting = create(:github_app_setting, key: "app_id", value: Random.rand(99999999).to_s)
          app_setting.value = "123abc"
          app_setting.validate # Trigger validation manually since we're testing on update
          expect(app_setting).not_to be_valid
          expect(app_setting.errors[:value]).to include("must be an integer!")
        end
      end

      context "public_link validation" do
        it "accepts valid URL" do
          app_setting = create(:github_app_setting, key: "public_link")
          app_setting.value = "https://github.com/apps/my-app"
          app_setting.validate # Trigger validation manually since we're testing on update
          expect(app_setting).to be_valid
        end

        it "rejects invalid URLs" do
          app_setting = create(:github_app_setting, key: "public_link")
          app_setting.value = "github.com"
          app_setting.validate # Trigger validation manually since we're testing on update
          expect(app_setting).not_to be_valid
          expect(app_setting.errors[:value]).to include("is invalid! Please enter a valid Public Link URL.")
        end

        it "allows blank values" do
          app_setting = create(:github_app_setting, key: "public_link")
          app_setting.value = ""
          app_setting.validate # Trigger validation manually since we're testing on update
          expect(app_setting).to be_valid
        end
      end
    end
  end

  describe "callbacks" do
    describe "#cleanup_value" do
      it "trims whitespace from the value" do
        app_setting = build(:github_app_setting, key: "cleanup_test", value: "  example  ")
        app_setting.valid?
        expect(app_setting.value).to eq("example")
      end

      it "doesn't modify nil values" do
        app_setting = build(:github_app_setting, key: "nil_test", value: nil)
        app_setting.valid?
        expect(app_setting.value).to be_nil
      end
    end
  end

  describe "edge cases" do
    it "validates non app_id or public_link keys without specific rules" do
      app_setting = build(:github_app_setting, key: "other_setting", value: "any value")
      expect(app_setting).to be_valid
    end

    it "allows updating a value" do
      app_setting = create(:github_app_setting, key: "updatable_setting", value: "original")
      app_setting.value = "updated"
      expect(app_setting).to be_valid
      app_setting.save
      expect(app_setting.reload.value).to eq("updated")
    end
  end
end
