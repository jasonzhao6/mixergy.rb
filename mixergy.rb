require 'csv'
require 'nokogiri'
require 'open-uri'

def scrape_to_csv
  url = 'http://mixergy.com/interviews/'
  page = Nokogiri::HTML(open(url))
  rows = page.css('#interview-archive-table tr')

  CSV.open('mixergy.csv', 'w') do |csv|
    csv << ['Episode', 'Date', 'Interview', 'Guest', 'Comments', 'URL']
    rows[1..-1].each do |row|
      csv << (row.css('td').map(&:text) << row.css('a')[0]['href'])
    end
  end
end

def guess_mp3_urls
  url_base = 'http://mixergy.com/wp-content/audio/'
  rows = CSV.read('mixergy.csv', headers:true)
  rows.map do |row|
    # Note: They don't have a consistent url scheme for their mp3 files.
    #       The following schemes cover a good number of them, but not all.
    puts "#{url_base}#{row['URL'].split('/')[-1]}-on-mixergy.mp3"
    puts "#{url_base}mixergy-#{row['URL'].split('/')[-1]}.mp3"
    puts "#{url_base}#{row['URL'].split('/')[-1]}-andrew.mp3"
    puts "#{url_base}#{row['URL'].split('/')[-1]}.mp3"
  end
end

scrape_to_csv
guess_mp3_urls
