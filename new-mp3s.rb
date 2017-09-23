# MP3s from latest interviews are not behind a paywall
# Run this script every couple of days to download them

# HOWTO:
# - if scraping all latest interviews, reset `LAST_SCRAPED_URL` to nil
# - run script, copy printed URLs into a download manager like JDownloader
# - follow instruction to set `LAST_SCRAPED_URL`

require 'nokogiri'
require 'open-uri'
require 'json'

LAST_SCRAPED_URL = 'https://mixergy.com/interviews/freeeup-with-nathan-hirsch/'

def latest_interview_urls
  url = 'https://mixergy.com/interviews/'
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
  mp3_line = open(interview_url).select{ |source_code| source_code =~ /mp3/ }.first
  json_start = mp3_line.index('{')
  json_end = mp3_line.rindex('}')
  json_object = JSON.parse(mp3_line[json_start..json_end])
  puts json_object['options']['url']
end

urls = latest_interview_urls
urls.each do |interview_url|
  print_mp3_url(interview_url)
  sleep 0.5
end

# Print instruction to reset `LAST_SCRAPED_URL`
if !urls.empty? && LAST_SCRAPED_URL != urls[0]
  puts
  puts 'TODO: set'
  puts "LAST_SCRAPED_URL = '#{ urls[0] }'"
end
