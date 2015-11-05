# MP3s from older episodes are behind a paywall
# But they are still download-able if you know the direct URL
# This script guesses the URLs based on a couple of known schemes
# The coverage is actually pretty poor

# HOWTO:
# - run script, copy printed URLs into a download manager like JDownloader

require 'csv'
require 'nokogiri'
require 'open-uri'

def scrape_to_csv
  url = 'http://mixergy.com/interviews/'
  page = Nokogiri::HTML(open(url))
  rows = page.css('#interview-archive-table tr')

  CSV.open('old-mp3s.csv', 'w') do |csv|
    # First row is the heading
    csv << rows[0].css('th').map(&:text) + ['URL']
    # The rest a are episodes
    rows[1..-1].each do |row|
      csv << (row.css('td').map(&:text) << row.css('a')[0]['href'])
    end
  end
end

def guess_mp3_urls
  url_base = 'http://mixergy.com/wp-content/audio/'
  rows = CSV.read('old-mp3s.csv', headers:true)
  rows.map do |row|
    puts "#{url_base}#{row['URL'].split('/')[-1]}-on-mixergy.mp3"
    puts "#{url_base}mixergy-#{row['URL'].split('/')[-1]}.mp3"
    puts "#{url_base}#{row['URL'].split('/')[-1]}-andrew.mp3"
    puts "#{url_base}#{row['URL'].split('/')[-1]}.mp3"
  end
end

scrape_to_csv
guess_mp3_urls
