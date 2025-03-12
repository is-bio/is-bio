class Setting < ApplicationRecord
  validates :key, presence: true, uniqueness: true
end
