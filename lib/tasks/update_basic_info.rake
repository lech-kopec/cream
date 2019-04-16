# TODO 

require 'nokogiri'
require_relative 'stock_scrape'
require_relative '../translators/income_statement'
require 'logger'

desc "Stocks seed from web"
task :update_basic_info => :environment do

  $logger = Logger.new('log/BiznesRadar.log')

  Rails.logger.level = Logger::DEBUG
  POOL = 10

  jobs = Queue.new
  Stock.not_banks.all.each do |stock|
    jobs.push stock
  end

  workers = POOL.times.map do 
    Thread.new do
      begin
        while stock = jobs.pop(true)
          puts jobs.length
          Scrape::BiznesRadar.assign_basic_details_to stock
        end
      rescue ThreadError
      end
    end
  end

  workers.map(&:join)

  #Stocks.not_banks.each do |stock|
    #Scrape::BiznesRadar.assign_basic_details_to stock
  #end
end
