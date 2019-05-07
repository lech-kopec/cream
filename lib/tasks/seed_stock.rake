require 'nokogiri'
require_relative 'stock_scrape'
require_relative '../translators/income_statement'
require 'logger'

desc "Stocks seed from web"
task :seed_stock => :environment do


  $logger = Logger.new('log/BiznesRadar.log')
  stock = Stock.find_by_ticker 'GKI'
  Scrape::BiznesRadar.extract_cash_flows(stock)
  Scrape::BiznesRadar.assign_income_statements_to stock
  Scrape::BiznesRadar.assign_balance_sheets_to(stock)
  Scrape::BiznesRadar.add_quarterly_balance_sheets(stock)
  Scrape::BiznesRadar.add_quarterly_income_statements(stock)
end
