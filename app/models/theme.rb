class Theme < ApplicationRecord
  validates :name, presence: true
  validates :enabled, presence: true, inclusion: [ true, false ]
  validates :free, presence: true, inclusion: [ true, false ]
  validates :color, presence: true, inclusion: (0..7).to_a
end
