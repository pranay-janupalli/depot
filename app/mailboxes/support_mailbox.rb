class SupportMailbox < ApplicationMailbox
  def process
    order=Order.where(email: mail.from_address.to_s).last
    SupportRequest.create(email: mail.from_address.to_s,subject: mail.subject,body: mail.body.to_s,order: order)
  end
end
