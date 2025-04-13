require 'rails_helper'

RSpec.describe Subdomain, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      locale = create(:locale)
      subdomain = build(:subdomain, value: "en", locale: locale)
      expect(subdomain).to be_valid
    end

    it "is not valid without a value" do
      subdomain = build(:subdomain, value: nil)
      expect(subdomain).not_to be_valid
      expect(subdomain.errors[:value]).to include("can't be blank")
    end

    it "is not valid without a locale" do
      subdomain = build(:subdomain, locale: nil)
      expect(subdomain).not_to be_valid
      expect(subdomain.errors[:locale]).to include("must exist")
    end

    it "is not valid with a duplicate value" do
      locale = create(:locale)
      create(:subdomain, value: "en", locale: locale)
      subdomain = build(:subdomain, value: "en", locale: locale)
      expect(subdomain).not_to be_valid
      expect(subdomain.errors[:value]).to include("has already been taken")
    end

    describe "value format validation" do
      it "is valid with lowercase letters" do
        locale = create(:locale)
        subdomain = build(:subdomain, value: "en", locale: locale)
        expect(subdomain).to be_valid
      end

      it "is valid with lowercase letters and numbers" do
        locale = create(:locale)
        subdomain = build(:subdomain, value: "en123", locale: locale)
        expect(subdomain).to be_valid
      end

      it "is valid with lowercase letters, numbers and hyphens" do
        locale = create(:locale)
        subdomain = build(:subdomain, value: "en-123", locale: locale)
        expect(subdomain).to be_valid
      end

      it "is not valid with uppercase letters" do
        locale = create(:locale)
        subdomain = build(:subdomain, value: "EN", locale: locale)
        expect(subdomain).not_to be_valid
        expect(subdomain.errors[:value]).to include("Can only contain lowercase letters, numbers, and hyphens, and cannot start or end with a hyphen")
      end

      it "is not valid with special characters" do
        locale = create(:locale)
        subdomain = build(:subdomain, value: "en@123", locale: locale)
        expect(subdomain).not_to be_valid
        expect(subdomain.errors[:value]).to include("Can only contain lowercase letters, numbers, and hyphens, and cannot start or end with a hyphen")
      end

      it "is not valid with leading hyphen" do
        locale = create(:locale)
        subdomain = build(:subdomain, value: "-en", locale: locale)
        expect(subdomain).not_to be_valid
        expect(subdomain.errors[:value]).to include("Can only contain lowercase letters, numbers, and hyphens, and cannot start or end with a hyphen")
      end

      it "is not valid with trailing hyphen" do
        locale = create(:locale)
        subdomain = build(:subdomain, value: "en-", locale: locale)
        expect(subdomain).not_to be_valid
        expect(subdomain.errors[:value]).to include("Can only contain lowercase letters, numbers, and hyphens, and cannot start or end with a hyphen")
      end
    end
  end

  describe "associations" do
    it "belongs to a locale" do
      locale = create(:locale)
      subdomain = create(:subdomain, locale: locale)
      expect(subdomain.locale).to eq(locale)
    end
  end
end 