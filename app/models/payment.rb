class Payment < ApplicationRecord
  belongs_to :order
  validates :chargeid, :status, :amount, presence: true
end
