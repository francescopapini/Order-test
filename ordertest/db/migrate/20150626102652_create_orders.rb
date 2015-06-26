class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.date :order_date
      t.integer :customer_id
      t.integer :supplier_id
      t.string :delivery_address
      t.float :total_order_value
      t.string :currency

      t.timestamps null: false
    end
  end
end
