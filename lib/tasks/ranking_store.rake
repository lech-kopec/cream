require "redis"
class BigDecimal
  def r2
    return self.round(2)
  end
end
class Float
  def r2
    return self.round(2)
  end
end

desc "Stocks seed from web"
task :ranking_store => :environment do

  redis = Redis.new

  stocks = Stock.not_banks.active

  sf = redis.get(stocks.to_sql)
  sf = Marshal.load(sf) if sf

  unless sf
    sf = ::StockFrames.stock_frames_from_relations(stocks)
    redis.set(stocks.to_sql, Marshal.dump(sf))
  end

  algo = StockFrames::Strategies::S5.new sf
  #results = algo.run(:algo, report_year: 2015)
  #puts results[-1]
  #results = algo.run(:algo, report_year: 2016)
  #puts results[-1]
  #results = algo.run(:algo, report_year: 2017)
  #puts results[-1]
  results = algo.run(:algo, report_year: 2018)

  File.open('ranking_dcf_01.csv', 'w+') do |f|
    results.each do |row|
      next unless row
      value = row.join(",") + "\n" if row.is_a? Array
      value = row + "\n" if !row.is_a? Array
      f.write(value)
      #puts value
    end
  end

end
