class User < ApplicationRecord
  has_secure_password

  enum :role, {
    requester:             0,
    supervisor:            1,
    director:              2,
    dispatcher:            3,
    dispatcher_supervisor: 4,
    driver:                5,
    admin:                 6
  }

  belongs_to :department, optional: true

  has_one  :driver_profile,  class_name: "Driver", foreign_key: :user_id, dependent: :destroy
  has_many :transport_requests, foreign_key: :requester_id,  dependent: :restrict_with_error
  has_many :reviewed_requests,  foreign_key: :reviewed_by_id, class_name: "TransportRequest"
  has_many :assigned_requests,  foreign_key: :assigned_by_id, class_name: "TransportRequest"
  has_many :notifications,      foreign_key: :recipient_id,   dependent: :destroy
  has_many :dispatched_assignments, foreign_key: :dispatcher_id, class_name: "Assignment"

  validates :first_name, :last_name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true

  before_save :downcase_email

  def full_name
    "#{first_name} #{last_name}"
  end

  def can_review?
    supervisor? || director? || admin?
  end

  def can_dispatch?
    dispatcher? || admin?
  end

  private

  def downcase_email
    self.email = email.downcase.strip
  end
end