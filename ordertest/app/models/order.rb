class Order < ActiveRecord::Base

  validates :order_date, :customer_id, :supplier_id, :delivery_address, :currency, :total_order_value_pence, presence: true
  validates :customer_id, :supplier_id, :total_order_value_pence, numericality: {greater_than_or_equal_to: 0}
  
  # used when importing .csv and .txt files
  def self.import(file)
   #case 1: importing CSV file
   if file.content_type.include? "csv" 

      # reads individual rows from the .csv file and creates a hash for each of them 
      CSV.foreach(file.path, headers: true) do |row|
        row.to_hash

# creates a new order from hash in case not present already in the database       
@order = self.create_order_from_hash(row["Order Date"], row["Customer ID"], row["Supplier ID"], row["Delivery Address"], row["Total Order Value"], row["Currency"])
end

# case 2: importing txt file
elsif file.content_type.include? "plain"

     # reads the lines in the .txt file and creates an array for each line with the individual order elements (first line as header) 
     lines = []
     File.open(file.path).each do |line|
       line = line.strip.split(";")
       line[3].gsub!(/"/, '')
       line[4].gsub!(".", '')
       lines << line
     end

    #creates an array of individual hashes for each order 
    rows = []
    for i in 1..(lines.length - 1) do
      rows[i-1] = {lines[0][0] => lines[i][0],
                   lines[0][1] => lines[i][1],
                   lines[0][2] => lines[i][2],
                   lines[0][3] => lines[i][3],
                   lines[0][4] => lines[i][4],
                   lines[0][5] => lines[i][5]}
    end 

    # checks if the date is in US or EU format and converts that into a standard rails format
    for i in 0..(rows.length - 1) do
      date = rows[i]["Order Date"].split("/")
      if rows[i][-1] = "USD"
       rows[i]["Order Date"] = Date.new(date[2].to_i, date[0].to_i, date[1].to_i)
     else
       rows[i]["Order Date"] = Date.new(date[2].to_i, date[1].to_i, date[0].to_i)
     end

# creates a new order from hash in case not present already in the database
@order = self.create_order_from_hash(rows[i]["Order Date"], rows[i]["Customer ID"], rows[i]["Supplier ID"], rows[i]["Delivery Address"], rows[i]["Total Order Value"], rows[i]["Currency"])
end

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
  total_order_value_pence.to_f / 100
end

# checks if there is already an existing order in the database
def self.order_already_exists(order_date, customer_id, supplier_id, delivery_address, currency, total_order_value_pence)
  order = self.find_by_order_date_and_customer_id_and_supplier_id_and_delivery_address_and_currency_and_total_order_value_pence(order_date, customer_id, supplier_id, delivery_address, currency, total_order_value_pence)
  if order.blank?
    return false
  else
    return true
  end
end

# creates a new order from a hash in case the order is not already in the database
def self.create_order_from_hash(order_date, customer_id, supplier_id, delivery_address, total_order_value, currency)
  order = self.new(order_date: order_date,
   customer_id: customer_id,
   supplier_id: supplier_id,
   delivery_address: delivery_address,
   total_order_value_pence: total_order_value.delete(",").delete(".").to_i,
   currency: currency)

  order.save if !self.order_already_exists(order.order_date, order.customer_id, order.supplier_id, order.delivery_address, order.currency, order.total_order_value_pence)
end

end
