class Order < ApplicationRecord
    has_many :payments
    has_many :order_items
    has_many :support_requests
    belongs_to :cart
    
    enum pay_type: {
        "debit card" => 0,
        "credit card" => 1
        
    }

    validates :name, :address, :email, presence: true
    validates :pay_type, inclusion: pay_types.keys

    

end
