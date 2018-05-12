require 'nokogiri'
require_relative '../PriceImporters/mstall_db'
require 'logger'

desc "Import stock prices for gwp from mstall_db"
task :import_gpw_mstall_db => :environment do

  $logger = Logger.new('log/BiznesRadar.log')
  Stock.not_banks.all.each do |stock|
    begin
      PriceImporters::MstallDB.import_historical(stock)
    rescue Errno::ENOENT => e
      $logger.warn("Missing price file for: ", stock.ticker)
    end
  end
end
