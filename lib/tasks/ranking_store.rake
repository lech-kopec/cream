desc "Stocks seed from web"
task :ranking_store => :environment do

  #ActiveRecord::Base.logger = Logger.new STDOUT

  start_year = 2010
  stocks = Stock.
            not_banks.
            active.
            includes(:income_statements, :balance_sheets, :cash_flows).
            references(:income_statements).
            references(:balance_sheets).
            references(:cash_flows).
            where(ticker: 'KGH').
            where("balance_sheets.year > #{start_year} and 
                  income_statements.year > #{start_year} and
                  cash_flows.year > #{start_year} and
                  income_statements.quarter is null and
                  balance_sheets.quarter is null and
                  cash_flows.quarter is null and
                  income_statements.year = balance_sheets.year and
                  cash_flows.year = balance_sheets.year").
            order("ticker").
            order("income_statements.year asc")

  sf = ::StockFrames.stock_frames_from_relations(stocks)

  File.open('kgh.dump', 'w+') do |f|
    Marshal.dump(sf, f)
  end

end
