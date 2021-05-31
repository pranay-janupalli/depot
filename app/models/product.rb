class Product < ApplicationRecord
    validates :product_name, presence: true, uniqueness: true
    validates :description, presence: true, length: { minimum: 10 }
    validates :price, presence: true, numericality:{ greater_than: 0, message: "Price should be numerical greater than 0"}
    validates :vendor, presence: true
    validates :image, presence: true
    has_one_attached :image
    has_many :line_items
    before_destroy :ensure_not_referenced_by_any_line_item

    private
    def ensure_not_referenced_by_any_line_item
        unless line_items.empty?
            errors.add(:base, 'Line Items present')
            throw :abort
        end
    end


end
