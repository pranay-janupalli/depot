class Order < ApplicationRecord
    has_many :line_items, dependent: :destroy
    enum pay_type: {
        "debit card" => 0,
        "credit card" => 1,
        "net banking" => 2
    }

    validates :name, :address, :email, presence: true
    validates :pay_type, inclusion: pay_types.keys

    def add_lineitems_from_cart(cart_object)
        cart_object.line_items.each do |item|
            item.cart_id=nil
            line_items << item
        end
    end

end
