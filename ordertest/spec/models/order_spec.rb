require 'rails_helper'

context "file process" do
  before(:each) do
    @file_csv = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/test.csv'), 'text/csv')
    @file_csv_broken = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/test_broken.csv'), 'text/csv')
    @file_txt = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/test.txt'), 'text/plain')
  end

  it "should be able to upload file" do
    expect(Order.import_file(@file_csv)).to eq @file_csv
    expect(Order.import_file(@file_txt)).to eq @file_txt
  end

  it "should add orders to the database after a file upload" do
    Order.import_file(@file_csv)
    Order.import_file(@file_txt)
    expect(Order.all.size).to eq 3
  end

  it "shouldn't add orders that already exists in database" do
    Order.import_file(@file_csv)
    expect(Order.all.size).to eq 1
    Order.import_file(@file_csv)
    expect(Order.all.size).to eq 1
    end

  it "shouldn't add orders when there's wrong information in file" do
    # the csv file has a negative customer ID
    Order.import_file(@file_csv_broken)
    expect(Order.all.size).to eq 0  
  end

  it "should convert all us dates in eu format" do
    date_us = "24/8/2014"
    date_eu = "24/10/2012"
    Order.convert_us_date_in_eu_format(date_us)
    Order.convert_us_date_in_eu_format(date_eu)
    expect(date_us).to eq "24/8/2014"
    expect(date_eu).to eq "24/10/2012"
  end

  it "shouldn't create an order with wrong parameters" do
    order = Order.create_order_from_hash("12/01/2010", "23", "33", "1 hyde park", "133", "USD")
    # wrong date
    Order.create_order_from_hash("24/24/2010", "23", "33", "1 hyde park", "133", "USD")
    #  negative customer id
    Order.create_order_from_hash("12/01/2010", "-10", "33", "1 hyde park", "133", "USD")
    # negative supplier id
    Order.create_order_from_hash("12/01/2010", "23", "-11", "1 hyde park", "133", "USD")
    # negative total value
    Order.create_order_from_hash("12/01/2010", "23", "-11", "1 hyde park", "-100", "USD")
    # wrong currency
    Order.create_order_from_hash("12/01/2010", "23", "-11", "1 hyde park", "-100", "XXX")
    
    expect(Order.all.size).to eq 1
    expect(order).to eq true
  end

end

