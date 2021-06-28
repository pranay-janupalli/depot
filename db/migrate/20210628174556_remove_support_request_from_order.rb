class RemoveSupportRequestFromOrder < ActiveRecord::Migration[6.1]
  def change
    remove_reference :support_requests, :order, null: false, foreign_key: true
  end
end
