require 'nokogiri'
require_relative 'stock_scrape'
require 'logger'

desc "Stocks seed from web"
task :seed_stocks => :environment do

  $logger = Logger.new('log/BiznesRadar.log')

  #Scrape::BiznesRadar.seed_from_index('https://www.biznesradar.pl/gielda/akcje_gpw', 'GPW')
  #Scrape::BiznesRadar.seed_from_index('https://www.biznesradar.pl/gielda/newconnect', 'NewConnect')

  Stock.not_banks.all.each do |stock|
    Scrape::BiznesRadar.seed_details(stock)
  end
  #puts "Missing: ", Translators::IncomeStatement.missing

  #stock = Stock.find_by_ticker '08N'
  #Scrape::BiznesRadar.seed_details(stock)
end
