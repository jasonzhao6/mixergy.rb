# MP3s from latest interviews are not behind a paywall
# Run this script every couple of days to download them

# HOWTO:
# - if scraping all latest interviews, reset `LAST_SCRAPED_URL` to nil
# - run script, copy printed URLs into a download manager like JDownloader
# - follow instruction to set `LAST_SCRAPED_URL`

require 'nokogiri'
require 'open-uri'

LAST_SCRAPED_URL = 'http://mixergy.com/interviews/ian-crosby-bench-accounting/'

def latest_interview_urls
  url = 'http://mixergy.com/interviews/'
  page = Nokogiri::HTML(open(url))
  interviews = page.css('.card.interview')
  urls = []

  interviews.each do |row|
    url = row.css('.content a')[0]['href']
    break if LAST_SCRAPED_URL == url
    urls << url
  end

  urls
end

def print_mp3_url(interview_url)
  page = Nokogiri::HTML(open(interview_url))
  puts page.css('source').first['src']
end

urls = latest_interview_urls
urls.each do |interview_url|
  print_mp3_url(interview_url) rescue break
  sleep 0.5
end

# Print instruction to reset `LAST_SCRAPED_URL`
if !urls.empty? && LAST_SCRAPED_URL != urls[0]
  puts
  puts 'TODO: set'
  puts "LAST_SCRAPED_URL = '#{ urls[0] }'"
end
