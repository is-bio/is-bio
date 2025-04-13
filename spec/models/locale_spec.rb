require 'rails_helper'

RSpec.describe Locale, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      locale = build(:locale, key: "en", english_name: "English", name: "English")
      expect(locale).to be_valid
    end

    it "is not valid without an id" do
      locale = build(:locale, key: nil)
      expect(locale).not_to be_valid
      expect(locale.errors[:id]).to include("can't be blank")
    end

    it "is not valid without an english_name" do
      locale = build(:locale, english_name: nil)
      expect(locale).not_to be_valid
      expect(locale.errors[:english_name]).to include("can't be blank")
    end

    it "is not valid without a name" do
      locale = build(:locale, name: nil)
      expect(locale).not_to be_valid
      expect(locale.errors[:name]).to include("can't be blank")
    end

    it "is not valid with a duplicate id" do
      create(:locale, key: "en")
      locale = build(:locale, key: "en")
      expect(locale).not_to be_valid
      expect(locale.errors[:id]).to include("has already been taken")
    end

    it "is not valid with a duplicate english_name" do
      create(:locale, english_name: "English")
      locale = build(:locale, english_name: "English")
      expect(locale).not_to be_valid
      expect(locale.errors[:english_name]).to include("has already been taken")
    end

    it "is not valid with a duplicate name" do
      create(:locale, name: "English")
      locale = build(:locale, name: "English")
      expect(locale).not_to be_valid
      expect(locale.errors[:name]).to include("has already been taken")
    end

    describe "id format validation" do
      it "is valid with two lowercase letters" do
        locale = build(:locale, key: "en")
        expect(locale).to be_valid
      end

      it "is valid with three lowercase letters" do
        locale = build(:locale, key: "pap")
        expect(locale).to be_valid
      end

      it "is valid with two lowercase letters followed by hyphen and lowercase letters" do
        locale = build(:locale, key: "zh-tw")
        expect(locale).not_to be_valid
      end

      it "is valid with two lowercase letters followed by hyphen and uppercase letters" do
        locale = build(:locale, key: "zh-TW")
        expect(locale).to be_valid
      end

      it "is valid with two lowercase letters followed by hyphen and uppercase 3 letters" do
        locale = build(:locale, key: "zh-YUE")
        expect(locale).to be_valid
      end

      it "is not valid with uppercase letters" do
        locale = build(:locale, key: "EN")
        expect(locale).not_to be_valid
        expect(locale.errors[:id]).to include("The first two characters are lowercase letters. The rest is empty. If it is not empty, it must start with \"-\"")
      end

      it "is not valid with less than two characters" do
        locale = build(:locale, key: "e")
        expect(locale).not_to be_valid
        expect(locale.errors[:id]).to include("The first two characters are lowercase letters. The rest is empty. If it is not empty, it must start with \"-\"")
      end

      it "is not valid with more than three characters without hyphen" do
        locale = build(:locale, key: "engl")
        expect(locale).not_to be_valid
        expect(locale.errors[:id]).to include("The first two characters are lowercase letters. The rest is empty. If it is not empty, it must start with \"-\"")
      end

      it "is not valid with hyphen but no additional characters" do
        locale = build(:locale, key: "en-")
        expect(locale).not_to be_valid
        expect(locale.errors[:id]).to include("The first two characters are lowercase letters. The rest is empty. If it is not empty, it must start with \"-\"")
      end
    end
  end

  describe "associations" do
    it "has many subdomains" do
      locale = create(:locale)
      subdomain = create(:subdomain, locale: locale)
      expect(locale.subdomains).to include(subdomain)
    end

    it "restricts deletion when subdomains exist" do
      locale = create(:locale)
      create(:subdomain, locale: locale)
      expect { locale.destroy }.to raise_error(ActiveRecord::DeleteRestrictionError)
    end
  end
end
