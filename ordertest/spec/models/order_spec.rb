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

it "shouldn't add orders with wrong information" do
  # the csv file has a negative customer ID
  Order.import_file(@file_csv_broken)
  expect(Order.all.size).to eq 0  
end




end

