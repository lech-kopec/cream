require 'nokogiri'
require_relative 'stock_scrape'
require_relative '../translators/income_statement'
require 'logger'

desc "Stocks seed from web"
task :import_cash_flows_bz_radar_MT => :environment do

  $logger = Logger.new('log/BiznesRadar.log')

  Rails.logger.level = Logger::DEBUG
  POOL = 10

  jobs = Queue.new
  Stock.not_banks.not_having_cf(2019,2).each do |stock|
    jobs.push stock
  end

  workers = POOL.times.map do 
    Thread.new do
      begin
        while stock = jobs.pop(true)
          puts jobs.length
          Scrape::BiznesRadar.extract_cash_flows(stock)
        end
      rescue ThreadError
      end
    end
  end

  workers.map(&:join)
end
