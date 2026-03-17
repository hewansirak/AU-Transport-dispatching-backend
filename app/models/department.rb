class Department < ApplicationRecord
  enum :name, {
    hr:              0,
    mis:             1,
    finance:         2,
    procurement:     3,
    legal:           4,
    communications:  5,
    administration:  6,
    peace_security:  7,
    infrastructure:  8,
    social_affairs:  9,
    executive_office: 10
  }

  has_many :users,              dependent: :nullify
  has_many :transport_requests, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
  validates :code, presence: true, uniqueness: { case_sensitive: false }
end