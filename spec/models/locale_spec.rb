require 'rails_helper'

RSpec.describe Locale, type: :model do
  # Clear data before tests
  before(:all) do
    Subdomain.delete_all
    Locale.delete_all
  end

  describe "validations" do
    it "is valid with valid attributes" do
      locale = build(:locale)
      expect(locale).to be_valid
    end

    it "is not valid without a key" do
      locale = build(:locale, key: nil)
      expect(locale).not_to be_valid
      expect(locale.errors[:key]).to include("can't be blank")
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

    it "is not valid with a duplicate key" do
      create(:locale, key: "aa")
      locale = build(:locale, key: "aa")
      expect(locale).not_to be_valid
      expect(locale.errors[:key]).to include("has already been taken")
    end

    it "is not valid with a duplicate english_name" do
      first_locale = create(:locale)
      locale = build(:locale, english_name: first_locale.english_name)
      expect(locale).not_to be_valid
      expect(locale.errors[:english_name]).to include("has already been taken")
    end

    it "is not valid with a duplicate name" do
      first_locale = create(:locale)
      locale = build(:locale, name: first_locale.name)
      expect(locale).not_to be_valid
      expect(locale.errors[:name]).to include("has already been taken")
    end

    describe "english_name and name cross-record uniqueness" do
      it "allows same english_name and name in the same record" do
        locale = build(:locale, english_name: "Same Value", name: "Same Value")
        expect(locale).to be_valid
      end

      it "is not valid when english_name matches another record's name" do
        first_locale = create(:locale, english_name: "Unique One", name: "Unique Two")
        locale = build(:locale, english_name: "Unique Two", name: "Something Else")
        expect(locale).not_to be_valid
        expect(locale.errors[:english_name]).to include("has already been used as 'name' in another record")
      end

      it "is not valid when name matches another record's english_name" do
        first_locale = create(:locale, english_name: "Unique Three", name: "Unique Four")
        locale = build(:locale, english_name: "Something Else", name: "Unique Three")
        expect(locale).not_to be_valid
        expect(locale.errors[:name]).to include("has already been used as 'english_name' in another record")
      end

      it "allows updating a record without changing english_name or name" do
        locale = create(:locale, english_name: "Update Test", name: "Update Test Value")
        locale.key = "zz"
        expect(locale).to be_valid
      end

      it "allows different english_name and name across records" do
        create(:locale, english_name: "Different One", name: "Different Value One")
        locale = build(:locale, english_name: "Different Two", name: "Different Value Two")
        expect(locale).to be_valid
      end
    end

    describe "key format validation" do
      it "is valid with two lowercase letters" do
        locale = build(:locale, key: "en")
        expect(locale).to be_valid
      end

      it "is valid with three lowercase letters" do
        locale = build(:locale, key: "pap")
        expect(locale).to be_valid
      end

      it "is valid with two lowercase letters followed by hyphen and uppercase letters" do
        locale = build(:locale, key: "zh-TW")
        expect(locale).to be_valid
      end

      it "is valid with three lowercase letters followed by hyphen and uppercase letters" do
        locale = build(:locale, key: "pap-ABC")
        expect(locale).to be_valid
      end

      it "is valid with two lowercase letters followed by hyphen and 2-3 uppercase letters" do
        locale = build(:locale, key: "en-US")
        expect(locale).to be_valid
      end

      it "is valid with two lowercase letters followed by hyphen and 2-3 digits" do
        locale = build(:locale, key: "en-123")
        expect(locale).to be_valid
      end

      it "is valid with two lowercase letters followed by hyphen and mix of uppercase letters and digits" do
        locale = build(:locale, key: "en-A1B")
        expect(locale).to be_valid
      end

      it "is not valid with two lowercase letters followed by hyphen and lowercase letters" do
        locale = build(:locale, key: "zh-tw")
        expect(locale).not_to be_valid
        expect(locale.errors[:key]).to include("The first two (or three) characters are lowercase letters. The rest is empty. If it is not empty, it must start with \"-\"")
      end

      it "is not valid with lowercase letters after hyphen" do
        locale = build(:locale, key: "en-abc")
        expect(locale).not_to be_valid
        expect(locale.errors[:key]).to include("The first two (or three) characters are lowercase letters. The rest is empty. If it is not empty, it must start with \"-\"")
      end

      it "is not valid with uppercase letters in prefix" do
        locale = build(:locale, key: "EN")
        expect(locale).not_to be_valid
        expect(locale.errors[:key]).to include("The first two (or three) characters are lowercase letters. The rest is empty. If it is not empty, it must start with \"-\"")
      end

      it "is not valid with less than two characters" do
        locale = build(:locale, key: "e")
        expect(locale).not_to be_valid
        expect(locale.errors[:key]).to include("The first two (or three) characters are lowercase letters. The rest is empty. If it is not empty, it must start with \"-\"")
      end

      it "is not valid with more than three characters without hyphen" do
        locale = build(:locale, key: "engl")
        expect(locale).not_to be_valid
        expect(locale.errors[:key]).to include("The first two (or three) characters are lowercase letters. The rest is empty. If it is not empty, it must start with \"-\"")
      end

      it "is not valid with hyphen but no additional characters" do
        locale = build(:locale, key: "en-")
        expect(locale).not_to be_valid
        expect(locale.errors[:key]).to include("The first two (or three) characters are lowercase letters. The rest is empty. If it is not empty, it must start with \"-\"")
      end

      it "is not valid with more than 3 characters after hyphen" do
        locale = build(:locale, key: "en-ABCD")
        expect(locale).not_to be_valid
        expect(locale.errors[:key]).to include("The first two (or three) characters are lowercase letters. The rest is empty. If it is not empty, it must start with \"-\"")
      end

      it "is not valid with special characters" do
        locale = build(:locale, key: "en-A@B")
        expect(locale).not_to be_valid
        expect(locale.errors[:key]).to include("The first two (or three) characters are lowercase letters. The rest is empty. If it is not empty, it must start with \"-\"")
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
