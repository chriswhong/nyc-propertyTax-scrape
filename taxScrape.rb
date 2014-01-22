require 'rubygems'
require 'mechanize'
require 'csv'


agent1 = Mechanize.new
agent2 = Mechanize.new

agent1.get ('http://nycserv.nyc.gov/NYCServWeb/NYCSERVMain')


agent1.cookie_jar.save_as 'cookies', :session => true, :format => :yaml
##p agent1.cookie_jar

agent2.cookie_jar = agent1.cookie_jar

output = File.new("output.csv","a")

CSV.foreach("107BBL2.csv") do |csvRow|

	bbl = csvRow[0]
	puts "Working on BBL " + bbl

	borough = bbl[0,1]

	block = bbl[1,5]

	lot = bbl[6,10]

	puts borough + " " + block + " " + lot



	#reqString = "ChannelType=ct/Browser|RequestType=rt/Business|SubSystemType=st/Payments|AgencyType=at/CityCollector|ServiceName=TAX_PAYMENT_HISTORY_BY_BBL|MethodName=NONE|ParamCount=undefined|BBL_BOROUGH=1|BLOCK=01117|LOT=0024|EASEMENT=  |PageID=PropertyTaxPaymentHistorySearch|LinkType=B|ADDRESS_BOROUGH=1|BUILDING_NUMBER=|STREET_ADDRESS=|APARTMENT_NUMBER=|DATE_RANGE=TAX_PAYMENT_HISTORY_BY_BBL|TP_BEGIN_MONTH=  |TP_BEGIN_DAY=  |TP_BEGIN_YEAR=  |TP_END_MONTH=  |TP_END_DAY=  |TP_END_YEAR=  |ACCOUNT_YEAR=  |ACCOUNT_TYPE= "

	reqString = "ChannelType=ct/Browser|RequestType=rt/Business|SubSystemType=st/Payments|AgencyType=at/CityCollector|ServiceName=TAX_PAYMENT_HISTORY_BY_BBL|MethodName=NONE|ParamCount=undefined|BBL_BOROUGH="
	reqString += borough
	reqString += "|BLOCK="
	reqString += block
	reqString += "|LOT="
	reqString += lot
	reqString += "|EASEMENT=  |PageID=PropertyTaxPaymentHistorySearch|LinkType=B|ADDRESS_BOROUGH=1|BUILDING_NUMBER=|STREET_ADDRESS=|APARTMENT_NUMBER=|DATE_RANGE=TAX_PAYMENT_HISTORY_BY_BBL|TP_BEGIN_MONTH=  |TP_BEGIN_DAY=  |TP_BEGIN_YEAR=  |TP_END_MONTH=  |TP_END_DAY=  |TP_END_YEAR=  |ACCOUNT_YEAR=  |ACCOUNT_TYPE= "

	page = agent2.post 'http://nycserv.nyc.gov/NYCServWeb/NYCSERVMain', 'NycservRequest' => reqString 
	
	puts  "Starting POST"

	title = page.search('title')

	if title.text.include? "Search"
		puts "I got a search page, no info for this BBL"
		output.print(bbl)
		output.print("\n")
	else
		puts "I got tax payment records!"

		rows = page.search('table')[2].search('table')[1].search('tr')

		print rows.length 
		puts " rows returned for this BBL"

		rows.each_with_index { |row, index|

			if index==0 
				next
			end


			output.print(bbl)
			output.print(",")

			columns = row.search('td')

			columns.each { |column|
				text = column.text.gsub("\u00A0","").strip.tr(",","")


				output.print(text)
				output.print(",")
			}

			

			output.print("\n")

		}
	end


	
puts "waiting..."
sleep(5)

end



