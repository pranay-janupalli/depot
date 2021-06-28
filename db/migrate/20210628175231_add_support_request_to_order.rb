class AddSupportRequestToOrder < ActiveRecord::Migration[6.1]
  def change
    add_reference :support_requests, :order, foreign_key: true
  end
end
