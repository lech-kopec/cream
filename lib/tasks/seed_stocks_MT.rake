require 'nokogiri'
require_relative 'stock_scrape'
require_relative '../translators/income_statement'
require 'logger'

desc "Stocks seed from web"
task :seed_stocks_MT => :environment do

  $logger = Logger.new('log/BiznesRadar.log')

  Rails.logger.level = Logger::DEBUG
  POOL = 1

  jobs = Queue.new
  Stock.not_banks.not_having_is_year(2018).all.each do |stock|
    jobs.push stock
  end

  workers = POOL.times.map do 
    Thread.new do
      begin
        while stock = jobs.pop(true)
          puts jobs.length
          Scrape::BiznesRadar.assign_income_statements_to stock
          Scrape::BiznesRadar.add_quarterly_income_statements stock
          Scrape::BiznesRadar.assign_balance_sheets_to(stock)
          Scrape::BiznesRadar.add_quarterly_balance_sheets(stock)
          Scrape::BiznesRadar.extract_cash_flows(stock)
        end
      rescue ThreadError
      end
    end
  end

  workers.map(&:join)
end
