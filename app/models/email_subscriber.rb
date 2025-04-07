# == Schema Information
#
# Table name: email_subscribers
#
#  id         :integer          not null, primary key
#  email      :string           not null
#  confirmed  :boolean          default(FALSE)
#  token      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_email_subscribers_on_email  (email) UNIQUE
#
class EmailSubscriber < ApplicationRecord
  validates :email, presence: true,
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "is not a valid email address" }

  validate :check_existing_subscription, on: :create

  before_create :generate_token

  scope :confirmed, -> { where(confirmed: true) }

  def confirm_subscription(token)
    unless self.token == token
      return false
    end

    update(confirmed: true, token: nil)
  end

  # Generates a new confirmation token
  def generate_new_token
    generate_token
    save
  end

  private

  def generate_token
    self.token = SecureRandom.urlsafe_base64(32)
  end

  def check_existing_subscription
    existing = EmailSubscriber.find_by(email: email)
    return unless existing

    if existing.confirmed
      errors.add(:email, :already_confirmed)
    else
      errors.add(:email, :pending_confirmation)
    end
  end
end
