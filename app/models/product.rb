class Product < ApplicationRecord
    validates :product_name, presence: true
    validates :description, presence: true, length: { minimum: 10 }
    validates :price, presence: true, numericality:{ greater_than: 0, message: "Price should be numerical greater than 0"}
    validates :vendor, presence: true
    validates :image, presence: true
    has_one_attached :image
end
