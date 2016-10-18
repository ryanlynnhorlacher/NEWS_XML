require 'redis'
require 'zip'
require 'mechanize'
require 'pry'
require 'crack'



red = Redis.new
file_names = []
mechanize = Mechanize.new

puts 'Finding available zip files'
page = mechanize.get('http://feed.omgili.com/5Rh5AMTrc4Pv/mainstream/posts')
array = page.search('table').search('tr')
puts "#{array.length - 7} files found"
array.slice(3, array.length - 4).each do |row|
	filename = row.search('td').first.content
	puts "Downloading #{filename}"
	mechanize.get("http://feed.omgili.com/5Rh5AMTrc4Pv/mainstream/posts/#{filename}").save!('./zip_file.zip')
	if File.zero?("./zip_file.zip") == false
		Zip::File.open('./zip_file.zip') do |zip_file|
			zip_file.each do |entry|
			    content = entry.get_input_stream.read
			    parsed = Crack::XML.parse(content)
			    if red.sadd("SNEWS_XML", "#{parsed["document"]["discussion_title"]}")
			    	red.rpush("NEWS_XML", content)
			    	puts "ADDED: #{parsed["document"]["discussion_title"]}"
			    else
			    	puts "ALREADY EXISTS: #{parsed["document"]["discussion_title"]}"
			    end
			end
		end
	end
end






