class OrderMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.order_mailer.recieved.subject
  #
  
  def recieved(order)
    @order = order

    mail to: order.email, subject: 'Order Confirmation'
  end
end
