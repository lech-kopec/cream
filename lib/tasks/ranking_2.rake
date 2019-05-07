
desc "Stocks seed from web"
task :ranking_2 => :environment do

  load 'app/lib/record_processing/stock_frame.rb'

  start_year = 2015

  #ActiveRecord::Base.logger = Logger.new STDOUT

  start = Time.now
  stocks = Stock
      .not_banks
      .active
      .select("*")
      .joins(:income_statements)
      .joins(:balance_sheets)
      .joins(:cash_flows)
      .where("balance_sheets.year > #{start_year}")
      .where("income_statements.year > #{start_year}")
      .where("cash_flows.year > #{start_year}")
      .order("ticker asc, balance_sheets.year desc")

  puts "Query time: #{Time.now - start}"

  sf = RecordProcessing.stock_frames_from_active_record(stocks)
  puts "Processing time: #{Time.now - start}"
  puts "rake task"
  binding.irb

end
