# == Schema Information
#
# Table name: resumes
#
#  id            :integer          not null, primary key
#  birth_date    :date
#  city          :string
#  email_address :string           not null
#  height        :integer
#  name          :string           not null
#  phone_number  :string
#  position      :string
#  summary       :text
#  title         :string           not null
#  weight        :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
require "rails_helper"

RSpec.describe Resume, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      resume = build(:resume, title: "My Resume", name: "John Doe", email_address: "john@example.com")
      expect(resume).to be_valid
    end

    it "requires a title" do
      resume = build(:resume, title: nil)
      expect(resume).not_to be_valid
      expect(resume.errors[:title]).to include("can't be blank")
    end

    it "requires a name" do
      resume = build(:resume, name: nil)
      expect(resume).not_to be_valid
      expect(resume.errors[:name]).to include("can't be blank")
    end

    it "requires an email address" do
      resume = build(:resume, email_address: nil)
      expect(resume).not_to be_valid
      expect(resume.errors[:email_address]).to include("can't be blank")
    end

    it "validates email format" do
      valid_emails = [ "user@example.com", "user.name@example.co.uk", "user+tag@example.com" ]
      invalid_emails = [ "user@", "user@.com", "user@example", "@example.com", "user.example.com" ]

      valid_emails.each do |email|
        resume = build(:resume, email_address: email)
        expect(resume).to be_valid
      end

      invalid_emails.each do |email|
        resume = build(:resume, email_address: email)
        expect(resume).not_to be_valid
        expect(resume.errors[:email_address]).to include("is not a valid email format")
      end
    end

    it "validates phone number format if present" do
      valid_phones = [ "+1 (555) 123-4567", "555-123-4567", "+442071234567", nil, "" ]
      invalid_phones = [ "abc123", "phone", "123@456", "555.123.4567!" ]

      valid_phones.each do |phone|
        resume = build(:resume, phone_number: phone)
        expect(resume).to be_valid
      end

      invalid_phones.each do |phone|
        resume = build(:resume, phone_number: phone)
        expect(resume).not_to be_valid
        expect(resume.errors[:phone_number]).to include("is not a valid phone number format")
      end
    end

    # it "validates birth_date is a valid date if present" do
    #   valid_dates = [ Date.today, Date.new(1990, 1, 1), nil ]
    #
    #   valid_dates.each do |date|
    #     resume = build(:resume, birth_date: date)
    #     expect(resume).to be_valid
    #   end
    #
    #   # Mock an invalid date scenario
    #   resume = build(:resume, birth_date: "invalid-date")
    #   # allow(Date).to receive(:parse).with("invalid-date").and_raise(ArgumentError)
    #   # expect(resume).not_to be_valid
    #   expect(resume).to be_valid
    #   resume.validate
    #   puts resume.birth_date.inspect
    #   expect(resume.errors[:birth_date]).to include("is not a valid date")
    # end
  end

  describe "creation" do
    it "can be created with valid attributes" do
      expect {
        create(:resume,
               title: "Developer Resume",
               name: "Jane Smith",
               email_address: "jane@example.com",
               phone_number: "+1 (555) 987-6543",
               birth_date: "1985-03-15",
               height: 175.5,
               weight: 68.2
        )
      }.to change(Resume, :count).by(1)
    end
  end
end
