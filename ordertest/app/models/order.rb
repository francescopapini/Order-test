class Order < ActiveRecord::Base

  validates :order_date, :customer_id, :supplier_id, :delivery_address, :currency, :total_order_value_pence, presence: true
  validates :customer_id, numericality: true
  validates :supplier_id, numericality: true 
  validates :total_order_value_pence, numericality: {greater_than_or_equal_to: 0}

  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      row.to_hash
      Order.create(order_date: row["Order Date"],
       customer_id: row["Customer ID"],
       supplier_id: row["Supplier ID"],
       delivery_address: row["Delivery Address"],
       total_order_value_pence: row["Total Order Value"] * 100,
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


  def convert_order_to_gbp_current_rate(total_order_value)
   fx = OpenExchangeRates::Rates.new
   if currency == "USD"
     new_value = fx.convert(total_order_value, from: "USD", :to => "GBP")
   elsif currency == "EUR"
     new_value = fx.convert(total_order_value, from: "EUR", :to => "GBP")
   else
    return total_order_value
  end
  return new_value
end

end
