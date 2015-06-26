class RemoveTotalOrderValueFromOrders < ActiveRecord::Migration
  def change
    remove_column :orders, :total_order_value, :float
  end
end
