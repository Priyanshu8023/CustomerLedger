class Order < ApplicationRecord
  belongs_to :user
  belongs_to :customer
  before_create :generate_order_number

  private

  def generate_order_number
    next_number = Order.maximum(:id).to_i + 1
    self.order_number = "ORD-#{next_number.to_s.rjust(4, '0')}"
  end
end
