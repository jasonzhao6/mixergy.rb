# MP3s from latest episodes are not behind a paywall
# Run this script every couple of days to download them

# HOWTO:
# - if scraping all latest episodes, reset `LAST_SCRAPED_ID` to nil
# - run script, copy printed URLs into a download manager like JDownloader
# - follow instruction to set `LAST_SCRAPED_ID`

require 'nokogiri'
require 'open-uri'

LAST_SCRAPED_ID = 1226

def latest_episodes
  url = 'http://mixergy.com/interviews/'
  page = Nokogiri::HTML(open(url))
  rows = page.css('#interview-archive-table tr')

  # First row is the heading
  # The rest are episodes
  rows[1..-1].map do |row|
    id = row.css('td:first').first.text.to_i
    next if LAST_SCRAPED_ID >= id
    url = row.css('a')[0]['href']
    { id: id, url: url }
  end.compact
end

def print_mp3_url(episode)
  url = episode[:url]
  page = Nokogiri::HTML(open(url))
  puts page.css('source').first['src']
end

episodes = latest_episodes
episodes.each do |episode|
  print_mp3_url(episode) rescue break
  sleep 0.5
end

# Print instruction to reset `LAST_SCRAPED_ID`
if !episodes.empty? && LAST_SCRAPED_ID != episodes[0][:id]
  puts
  puts 'TODO:'
  puts "set LAST_SCRAPED_ID = #{ episodes[0][:id] }"
end
