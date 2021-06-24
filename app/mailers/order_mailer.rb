class OrderMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.order_mailer.recieved.subject
  #
  
  def recieved
    @greeting = "Hi"

    mail to: "pranay.janupalli@gmail.com"
  end
end
