require 'redis'
require 'zip'
require 'wget/version/version.rb'
require 'mechanize'
require 'pry'
require 'json'
require 'crack'


red = Redis.new

file_names = []

mechanize = Mechanize.new
page = mechanize.get('http://feed.omgili.com/5Rh5AMTrc4Pv/mainstream/posts')
array = page.search('table').search('tr')
array.slice(3, array.length - 4).each do |row|
	file_names << row.search('td').first.content
end

file_names.each do |file_name|

	file = `wget -O zip_file.zip http://feed.omgili.com/5Rh5AMTrc4Pv/mainstream/posts/"#{file_name}"`
	if File.zero?("./zip_file.zip") == false
		Zip::File.open('./zip_file.zip') do |zip_file|
			zip_file.each do |entry|
			    content = entry.get_input_stream.read
			    parsed = Crack::XML.parse(content)
			    if red.sadd("SNEWS_XML", "#{parsed["document"]["discussion_title"]}")
			    	red.rpush("NEWS_XML", content)
			    	puts "Added #{parsed["document"]["discussion_title"]}"
			    else
			    	puts "SKIPPING THIS ONE!"
			    end
			end
		end
	end
end




