class Order < ActiveRecord::Base

  validates :order_date, :customer_id, :supplier_id, :delivery_address, :currency, :total_order_value_pence, presence: true
  validates :customer_id, numericality: {greater_than_or_equal_to: 0}
  validates :supplier_id, numericality: {greater_than_or_equal_to: 0}
  validates :total_order_value_pence, numericality: {greater_than_or_equal_to: 0}

  def self.import(file)
    if file.content_type.include? "csv" 
      CSV.foreach(file.path, headers: true) do |row|
        row.to_hash
        Order.create(order_date: row["Order Date"],
         customer_id: row["Customer ID"],
         supplier_id: row["Supplier ID"],
         delivery_address: row["Delivery Address"],
         total_order_value_pence: (row["Total Order Value"].to_f * 100).to_i,
         currency: row["Currency"])
      end

    elsif file.content_type.include? "plain" 

      lines = []
      File.open(file.path).each do |line|

       line = line.strip.split(";")
  
      
       line[3].gsub!(/"/, '')
       line[4].gsub!(".", '')
       lines << line
     end

     rows = {}
     for i in 1..(lines.length - 1) do
      rows[i-1] = {lines[0][0] => lines [i][0], lines[0][1] => lines [i][1], lines[0][2] => lines[i][2], lines[0][3] => lines[i][3], lines[0][4] => lines[i][4], lines[0][5] => lines[i][5]}
    end 

    for i in 0..(rows.length - 1) do
      date = rows[i]["Order Date"].split("/")
      if rows[-1] = "USD"
       rows[i]["Order Date"] = Date.new(date[2].to_i, date[0].to_i, date[1].to_i)
      else
       rows[i]["Order Date"] = Date.new(date[2].to_i, date[1].to_i, date[0].to_i)
       end


      @order = Order.create(order_date: rows[i]["Order Date"],
       customer_id: rows[i]["Customer ID"],
       supplier_id: rows[i]["Supplier ID"],
       delivery_address: rows[i]["Delivery Address"],
       total_order_value_pence: (rows[i]["Total Order Value"].to_f * 100).to_i,
       currency: rows[i]["Currency"])
    end
      binding.pry

    else
    end

  end


# converts an order from default currency (USD) into any rate for the specified date
def convert_order_to_historical_rate(total_order_value, rate, conversion_date)
 fx = OpenExchangeRates::Rates.new
 if conversion_date > DateTime.now
  if currency == "USD"
    new_value = fx.convert(total_order_value, from: "USD", to: rate)
  elsif currency == "EUR"
   new_value = fx.convert(total_order_value, from: "EUR", to: rate)
 else
   return total_order_value
 end
else
  if currency == "USD"
    new_value = fx.convert(total_order_value, from: "USD", to: rate, on: conversion_date.to_s)
  elsif currency == "EUR"
   new_value = fx.convert(total_order_value, from: "EUR", to: rate, on: conversion_date.to_s)
 else
   return total_order_value
 end
end
return new_value
end

def total_order_value
  total_order_value_pence / 100
end

end
