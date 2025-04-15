# == Schema Information
#
# Table name: themes
#
#  id      :integer          not null, primary key
#  name    :string           not null
#  enabled :boolean          default(TRUE), not null
#  free    :boolean          default(TRUE), not null
#  color   :integer          default(1), not null
#

FactoryBot.define do
  factory :theme do
    sequence(:name) { |n| "Theme #{n}" }
    enabled { true }
    free { true }
    color { rand(1..8) }

    trait :disabled do
      enabled { false }
    end

    trait :premium do
      free { false }
    end

    # Traits for specific colors
    trait :color_1 do
      color { 1 }
    end

    trait :color_2 do
      color { 2 }
    end

    trait :color_3 do
      color { 3 }
    end
  end
end
