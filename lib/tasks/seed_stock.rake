require 'nokogiri'
require_relative 'stock_scrape'
require_relative '../translators/income_statement'
require 'logger'

desc "Stocks seed from web"
task :seed_stock => :environment do


  stock = Stock.find_by_ticker 'AIN'
  Scrape::BiznesRadar.assign_income_statements_to stock
  #Scrape::BiznesRadar.assign_balance_sheets_to(stock)
  #Scrape::BiznesRadar.add_quarterly_balance_sheets(stock)
  #Scrape::BiznesRadar.add_quarterly_income_statements(stock)
end
