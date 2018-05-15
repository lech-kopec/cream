require 'nokogiri'
require_relative 'stock_scrape'
require_relative '../translators/income_statement'
require 'logger'

desc "Stocks seed from web"
task :seed_stocks => :environment do

  $logger = Logger.new('log/BiznesRadar.log')

  #Scrape::BiznesRadar.seed_from_index('https://www.biznesradar.pl/gielda/akcje_gpw', 'GPW')
  #Scrape::BiznesRadar.seed_from_index('https://www.biznesradar.pl/gielda/newconnect', 'NewConnect')

  Stock.not_banks.all.each do |stock|
    Scrape::BiznesRadar.seed_details(stock)
  end
  puts "Missing: ", Translators::BzRadar.missing

  #stock = Stock.find_by_ticker '11B'
  #Scrape::BiznesRadar.seed_details(stock)
end
