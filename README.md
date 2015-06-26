# Exampl.biz Commerce Challenge
Exampl.biz has a commerce business with overseas offices. They are building a way to display sales information on a web page, which will be called using the order_id.

Currently, they use spreadsheets to keep track of orders. Unfortunately, some of the data has been kept in different formats and currencies.

Using the standards outlined below, please complete the following:

 1. Build a simple Rails app which will import the orders from the    .csv or .txt files in the /data folder and save them in a database.
 2. Add an index page for the order information.
 3.  Ensure that each order can be queried using a json GET request (see desired JSON response below) or an HTML GET request.
 4.  Ensure that the currency conversion is taken from the historical value on the date of the order (see Exchange Rates below).

The app should be designed to be suitable for production.

## STANDARDS

### Authentication & Authorisation
 - None required

### Gems
 - Gems may be used

### Exchange Rates
 - Realtime and historical currency information should be taken from the API http://openexchangerates.org/api/
 (There is a free account: https://openexchangerates.org/signup/free)
 - GBP should have an exchange rate of 1:1

### Date Formats
Input values:
Know date formats include:

 - mm/dd/yyyy
 - mm-dd-yyyy
 - mm-dd-yy
 - dd/mm/yyyy
 - dd-mm-yyyy
 - dd-mm-yy
 - strftime, e.g. 'Sat, 10 Nov 2007'

Output values should be:

 - "mm-dd-yyyy"

### Currency formats:
Currency codes can include: GBP, USD, EUR
Input values include:

 - 1,000.00 (US)
 - 1.000,00 (Europe)
 - 1000
 - 1000.00

Output values should be returned in GBP:

 - 1,000.00

### JSON output

Desired JSON response:

    {
	order: {
		id: number,
			customer: {
				id: number
			},
			supplier: {
				id: number
			},
			date: date, #date formatted as mm-dd-yyyy
			total_order_value: {
				local_currency_code: string,
				local_value: string, #formatted at 1,234.56
				value: string, #formatted at 1,234.56
			}
		}
	}

Example:

    {
		order: {
		id: 7,
			customer: {
				id: 23
			},
			supplier: {
				id: 54
			},
			date: '12-16-2014',
			total_order_value: {
				local_currency: 'USD',
				local_value: '1,023.00',
				value: '1,234.56'
			}
		}
	}