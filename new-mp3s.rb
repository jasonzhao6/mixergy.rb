# MP3s from new episodes are downloadable
# They'll be behind a paywall in about a week

# HOWTO:
# - set `LAST_SCRAPED_URL` to nil to download all episodes not yet behind a paywall
# - run script weekly, copy printed URLs into a download manager like JDownloader
# - follow printed TODO and update `LAST_SCRAPED_URL` in this file

require 'nokogiri'
require 'open-uri'
require 'json'

LAST_SCRAPED_URL = 'https://mixergy.com/interviews/with-sachit-gupta/'

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
  return unless mp3_line

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
  puts 'TODO: update'
  puts "LAST_SCRAPED_URL = '#{ urls[0] }'"
end
