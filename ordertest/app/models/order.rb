class Order < ActiveRecord::Base

  validates :order_date, :customer_id, :supplier_id, :delivery_address, :currency, :total_order_value_pence, presence: true
  validates :customer_id, :supplier_id, :total_order_value_pence, numericality: {greater_than_or_equal_to: 0}
  
  def self.import(file)  
    if file.content_type.include? "csv" 
      self.import_csv(file)
    elsif file.content_type.include? "plain"
      self.import_txt(file)
    else
    end
  end

  # converts an order from default currency (USD) into any rate for the specified date
  def convert_order_to_historical_rate(total_order_value, rate, conversion_date)
    fx = OpenExchangeRates::Rates.new
    if currency == "USD"
      new_value = fx.convert(total_order_value, from: "USD", to: rate, on: conversion_date.to_s)
    elsif currency == "EUR"
      new_value = fx.convert(total_order_value, from: "EUR", to: rate, on: conversion_date.to_s)
    else
      return total_order_value
    end
    return new_value
  end

  def total_order_value
    total_order_value_pence.to_f / 100
  end

  # reads individual rows from the .csv file and creates a hash for each of them 
  def self.import_csv(file)
    CSV.foreach(file.path, headers: true) do |row|
      row.to_hash
      eu_date = self.convert_us_date_in_eu_format(row["Order Date"])       
      order = self.create_order_from_hash(eu_date, row["Customer ID"], row["Supplier ID"], row["Delivery Address"], row["Total Order Value"], row["Currency"])
    end
  end

  def self.import_txt(file)
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
      rows[i-1] = {}
      for j in 0..(lines[i].length - 1) do
        rows[i-1][lines[0][j]] = lines[i][j]
      end 
    end 

    for i in 0..(rows.length - 1) do
      eu_date = self.convert_us_date_in_eu_format(rows[i]["Order Date"])
      order = self.create_order_from_hash(eu_date, rows[i]["Customer ID"], rows[i]["Supplier ID"], rows[i]["Delivery Address"], rows[i]["Total Order Value"], rows[i]["Currency"])
    end
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

# check if a date is in us format and converts it in eu format
  def self.convert_us_date_in_eu_format(date_string)
    date = date_string.split("/")
    if date[1].to_i > 12
      new_date_string = "#{date[1]}/#{date[0]}/#{date[2]}"
      return new_date_string
    end
    return date_string 
  end

end
