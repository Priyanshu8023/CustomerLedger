class AddOrderNumberToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :order_number, :string unless column_exists?(:orders, :order_number)
  end
end
