class Cart < ApplicationRecord
    has_many :line_items, dependent: :destroy
    has_one :order

    def add_product(product)
        current_item = line_items.find_by(product_id: product.id)
        if current_item
          current_item.quantity += 1
        else
          current_item = line_items.build(product_id: product.id)
          current_item.quantity ||= 1
        end
        current_item
    end

    def remove_product(product)
      current_item = line_items.find_by(product_id: product.id)
      if current_item.quantity > 1
        current_item.quantity -= 1
      else
        
      end
      current_item
    end

    def total_price
        line_items.to_a.sum { |item| item.total_price }
    end

    def self.quantity_count(id)
      (id) ? Cart.find(id).line_items.sum { |x| x['quantity']} : 0
    end




end
