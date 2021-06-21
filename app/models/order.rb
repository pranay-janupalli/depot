class Order < ApplicationRecord
    has_many :order_items
    belongs_to :cart
    
    enum pay_type: {
        "debit card" => 0,
        "credit card" => 1,
        "net banking" => 2
    }

    validates :name, :address, :email, presence: true
    validates :pay_type, inclusion: pay_types.keys

    

end
