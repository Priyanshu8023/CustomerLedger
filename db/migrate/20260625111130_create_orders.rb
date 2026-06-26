class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    unless table_exists?(:orders)
      create_table :orders do |t|
        t.decimal :total_amount
        t.string :status
        t.date :order_date
        t.text :notes
        t.references :user, null: false, foreign_key: true
        t.references :customer, null: false, foreign_key: true

        t.timestamps
      end
    end

    if column_exists?(:orders, :amount) && !column_exists?(:orders, :total_amount)
      rename_column :orders, :amount, :total_amount
    end

    unless column_exists?(:orders, :user_id)
      add_reference :orders, :user, null: false, foreign_key: true
    end
  end
end
