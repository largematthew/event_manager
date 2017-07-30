require "csv"
require "sunlight/congress"
require "erb"

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

def clean_zipcodes(zipcode)
	zipcode.to_s.rjust(5, "0")[0..4]
end

def clean_phonenumber(phonenumber)
	case phonenumber.to_s
		when phonenumber.length == 11 && phonenumber[0] == "1"
			return phonenumber[1..10]
		when phonenumber.length == 10
			return phonenumber
		else
			return "invalid"
	end
end

def legislators_by_zipcode(zipcode)
	Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def save_letters(id, personal_letter)
	Dir.mkdir("output") unless Dir.exists? "output"
	
	filename = "output/thanks_#{id}.html"
	
	File.open(filename, "w") do |file|
		file.puts personal_letter
end
	
def generate_hour_report(filename)
	content = CSV.open "../#{filename}", headers: true, header_converters: :symbol
	content.each do |row|
		result = Array.new(23,0)
		hour = DateTime.strptime(row[:RegDate], "%m/%d/%Y %H:%M").strftime("%H")
		result[(hour.to_i-1)] += 1
	end
	puts "The most popular hour for registrations was #{result.max}:00"
end
	
def generate_day_report(filename)
	content = CSV.open "../#{filename}", headers: true, header_converters: :symbol
	content.each do |row|
		result = Array.new(7,0)
		date = DateTime.strptime(row[:RegDate], "%m/%d/%Y %H:%M").strftime("%Y,%m,%d")
		day = Date.new(date).wday
		result[(day.to_i)] += 1
		DOW = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
	end
	puts "The most popular day of the week for registrations was #{DOW[result.max.index]}"
end

template = File.read "../form_letter.html"
erb_template = ERB.new template

puts "Event manager initialized!"

content = CSV.open "../event_attendees.csv", headers: true, header_converters: :symbol
content.each do |row|
	id = row[0]
	
	name = row[:first_name]
	
	phonenumber = clean_phonenumber(:HomePhone)
	
	zipcode = clean_zipcodes(row[:zipcode])
	
	legislators = legislators_by_zipcode(zipcode)
	
	personal_letter = erb_template.result(binding)

	save_letters(id, personal_letter)
	
end
