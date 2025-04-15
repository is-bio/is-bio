class Theme < ApplicationRecord
  COLORS = [ "", "5FCB71", "5BC3D5", "3B7EEB", "5ECCA9", "EEA73B", "5469C9", "5D6BA7", "6C51A4" ]

  validates :name, presence: true
  validates :enabled, presence: true, inclusion: [ true, false ]
  validates :free, presence: true, inclusion: [ true, false ]
  validates :color, presence: true, inclusion: (1..8).to_a
  validate :at_least_one_enabled, on: :update, if: -> { enabled_changed? && !enabled? }

  after_save :ensure_only_one_enabled, if: -> { enabled? && saved_change_to_enabled? }

  def self.enabled
    find_by(enabled: true)
  end

  private

  def ensure_only_one_enabled
    Theme.where.not(id: id).update_all(enabled: false)
  end

  def at_least_one_enabled
    if !enabled? && Theme.where(enabled: true).count <= 1
      errors.add(:enabled, "At least one theme must be enabled")
    end
  end
end
