require 'nokogiri'
require 'colorize'
require 'httparty'
require 'pry'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

@funkysouls_url = "https://funkysouls.org/"
@album_of_the_year_url = "https://www.albumoftheyear.org/releases/this-week/"
@bag_of_holding = []
@artistArray = []
@albumArray = []

def parse_the_page(url)

html = HTTParty.get(url)
parsed = Nokogiri::HTML.parse(html)

	if url == @funkysouls_url || url.include?('funkysouls')
	
		@doc = parsed.css('h2>a')
		
	elsif url == @album_of_the_year_url || url.include?('albumboftheyear')
	
		#@doc = parsed.css('div>div>div>a>div') #Returns an array where the first one is the Artist Title and the second is the AlbumTitle.
		@doc = parsed.css('div>div>div>a>div')

	end

end

def sort_for_list_album_of_the_year(parsed_document)

	@doc.each do |aa|
		puts aa.values.to_s
		if aa.values.include?("artistTitle") == true
			@artistArray << aa.text.to_s
		elsif aa.values.include?("albumTitle") == true
			@albumArray << aa.text.to_s
		end
	end
	
	mashem = @artistArray.zip(@albumArray)

	mashem.each do |t|
		carve_in_rock("AlbumOfTheYear", t[0], t[1])
	end
	
end




def sort_for_list_funkysouls(parsed_document)

parsed_document.each do |s|
	if (s.values[1].include?("[2021]") || s.values[1].include?("[2020]"))
		@split_them_up = s.values[1].gsub(/[\u2013]/,'-').encode('ASCII', invalid: :replace, undef: :replace, replace: "").split(' - ')
		puts @split_them_up
		@split_them_up[1].gsub!('[2021]', '')
		@split_them_up[1].gsub!('[2020]', '')
		@split_them_up[1].strip!
		carve_in_rock(s.values[0], @split_them_up[0], @split_them_up[1])
		puts s.values[0], @split_them_up[0], @split_them_up[1].green
	else
		puts "Nothing Here Folks".red
	end
end
end

def carve_in_rock(data, artist, title)
File.open("list.txt", "a") {|f| f.write(data + "," + artist + "," + title + "\n") }
end

def next_phase_funkysouls()

for i in 2..5
	
	@url = "https://funkysouls.org/page/#{i}.html"
	parse_the_page(@url)
	sort_for_list_funkysouls(@doc)
next i
end
end

parse_the_page(@funkysouls_url)
sort_for_list_funkysouls(@doc)
next_phase_funkysouls()
parse_the_page(@album_of_the_year_url)
sort_for_list_album_of_the_year(@doc)




#https://www.albumoftheyear.org/releases/this-week/
#	#centerContent > div.flexContainer > div.wideLeft > div:nth-child(4) > a:nth-child(2) > div; //*[@id="centerContent"]/div[1]/div[1]/div[3]/a[1]/div
#https://www.officialcharts.com/new-releases/
#https://www.allmusic.com/newreleases
#https://www.metacritic.com/browse/albums/release-date/new-releases/date
