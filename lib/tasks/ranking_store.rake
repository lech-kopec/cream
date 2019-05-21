require "redis"

desc "Stocks seed from web"
task :ranking_store => :environment do

  #ActiveRecord::Base.logger = Logger.new STDOUT

  redis = Redis.new

  stocks = Stock.not_banks.active

  sf = redis.get(stocks.to_sql)
  sf = Marshal.load(sf) if sf

  unless sf
    sf = ::StockFrames.stock_frames_from_relations(stocks)
    redis.set(stocks.to_sql, Marshal.dump(sf))
  end

  algo = StockFrames::Strategies::S2.new sf
  results = algo.run(:algo, report_year: 2015)
  puts results[-1]
  results = algo.run(:algo, report_year: 2016)
  puts results[-1]
  results = algo.run(:algo, report_year: 2017)
  puts results[-1]

  #File.open('ranking_dcf_01', 'w+') do |f|
    #results.each do |row|
      #next unless row
      #f.write(row.join(",") + "\n") if row.is_a? Array
      #f.write(row + "\n") if !row.is_a? Array
    #end
  #end

  #File.open('kgh.dump', 'w+') do |f|
    #Marshal.dump(sf, f)
  #end

end
