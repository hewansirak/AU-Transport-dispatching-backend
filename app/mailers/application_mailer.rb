class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAILER_FROM", "transport@au.int")
  layout false
end