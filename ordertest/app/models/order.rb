class Order < ActiveRecord::Base

  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      row.to_hash
      Order.create(order_date: row["Order Date"],
       customer_id: row["Customer ID"],
       supplier_id: row["Supplier ID"],
       delivery_address: row["Delivery Address"],
       total_order_value_pence: row["Total Order Value"] * 1000,
       currency: row["Currency"])
    end
  end


  # def self.import(file)
  # lines = []
  # File.open(file.path).each do |line|
  #      line = line.strip.split
  #      lines << line
  #    end
  #    for i in 1..lines.length - 1 do
  #     Order.create(order_date: lines[i][0],
  #                  customer_id: lines[i][1],
  #                  supplier_id: lines[i][2],
  #                  delivery_address: lines[i][3],
  #                  total_order_value: lines[i][4],
  #                  currency: lines[i][5])
  #   end
  #   binding.pry
  # end


end
