class AddTotalOrderValuePenceToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :total_order_value_pence, :integer
  end
end
