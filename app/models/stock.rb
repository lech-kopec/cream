class Stock < ApplicationRecord
  ActiveRecord::Base.logger = nil

  belongs_to :market

  has_many :income_statements
  has_many :balance_sheets
  has_many :cash_flows
  has_many :prices

  validates :name, presence: true, uniqueness: true

  scope :not_banks, lambda { id = Sector.find_by_name('Banks'); where("sector_id != ?", id) }

  def self.test1
    start_time = Time.now
    matrix = []
    header = ["ticker", "cash", "liabilities", "market_cap", 'net_profit_sum', "years_to_repay", "years_to_mc", "fair_value", 'market_to_fair_value']
    Stock.not_banks.all.each do |stock|
      unless stock.prices.latest.present?
        #puts "Skipping: ", stock.ticker
        next
      end

      net_profit_sum = stock.income_statements.where("year >= 2016").select("coalesce(sum(net_profit),0) as net_p_sum")[0].net_p_sum
      liabilities = stock.balance_sheets.where("year = 2017").select("coalesce(short_term_liabilities,0) as stl, coalesce(long_term_liabilities,0) as ltl")[0]
      unless liabilities.present?
        #puts "Skippingm, no liabilities: " + stock.ticker
        next
      end
      liabilities = liabilities.ltl + liabilities.stl
      cash = stock.balance_sheets.order(year: :desc).select("coalesce(cash,0) as cash")[0].cash
      current_price = stock.prices.latest.close
      market_cap = (stock.shares * current_price) / 1000
      average_year = net_profit_sum / 2
      years_to_repay = (liabilities - cash ) / average_year
      years_to_mc = years_to_repay + ( market_cap / average_year )
      fair_value = (Stock.discount(average_year, 6, 10) + cash - liabilities) / (stock.shares/1000)
      market_to_fair_value = (fair_value/current_price - 1) * 100
      matrix.push [stock.ticker, cash, liabilities, market_cap, net_profit_sum.round(2), years_to_repay.round(2), years_to_mc.round(2), fair_value.round(2), market_to_fair_value.round(2)]
    end
    end_time = Time.now
    puts "Calc time: "+(end_time - start_time).to_s

    sort_by = -1
    matrix.sort! {|x,y| y[sort_by] <=> x[sort_by]}

    rjust = 12
    header.map! {|x| x.rjust(rjust)}
    puts header.join(',')
    counter = 0
    matrix.each_with_index do |row, index|
      if row[-5] > 0
        row.map! {|x| x.to_s.rjust(rjust)}
        puts row.join(',')
        counter += 1
        break if counter > 20
      end
    end
    end_time = Time.now
    puts end_time - start_time
    return nil

  end

  def self.test2
    start_time = Time.now
    # row should contain
    # "ticker", "cash", "liabilities", "market_cap", 'net_profit_sum', EV, "years_to_repay", "avg_years_to_ev", "fair_value", 'market_to_fair_value' score
    matrix = {}
    results = Stock.not_banks.select("*").joins(:income_statements).joins(:balance_sheets).joins("join prices on prices.id = (select id from prices where prices.stock_id = stocks.id order by time desc limit 1)").where("balance_sheets.year = income_statements.year").where("balance_sheets.year in (2016, 2017) and income_statements.year in (2016, 2017)").order("ticker asc, balance_sheets.year desc")
    results.each do |stock|
      matrix[stock.ticker] = {} unless matrix[stock.ticker]
      matrix[stock.ticker][:net_profit_sum] = 0 unless matrix[stock.ticker][:net_profit_sum]
      matrix[stock.ticker][:net_profit_sum] += stock.net_profit.to_f.round(2)

      matrix[stock.ticker][:cash] = (stock.cash if stock.year == 2017).to_f.round(2)

      matrix[stock.ticker][:liabilities] = (stock.short_term_liabilities.to_f + stock.long_term_liabilities.to_f + stock.accrued_expenses.to_f).round(2) if stock.year == 2017


      current_price = stock.close.round(2)
      if !current_price || !matrix[stock.ticker][:liabilities]
        matrix.delete stock.ticker
        next
      end

      market_cap = (stock.shares * current_price) / 1000
      matrix[stock.ticker][:market_cap] = market_cap.round(2)

      average_year = matrix[stock.ticker][:net_profit_sum] / 2
      years_to_repay = (matrix[stock.ticker][:liabilities] - matrix[stock.ticker][:cash] ) / average_year
      matrix[stock.ticker][:years_to_repay] = 0 unless matrix[stock.ticker][:years_to_repay]
      matrix[stock.ticker][:years_to_repay] = years_to_repay.round(2)

      years_to_mc = years_to_repay + ( market_cap / average_year )
      matrix[stock.ticker][:years_to_mc] = 0 unless matrix[stock.ticker][:years_to_mc]
      matrix[stock.ticker][:years_to_mc] = years_to_mc.round(2)

      fair_value = (Stock.discount(average_year, 6, 10) + matrix[stock.ticker][:cash] - matrix[stock.ticker][:liabilities]) / (stock.shares/1000)
      matrix[stock.ticker][:fair_value] = 0 unless matrix[stock.ticker][:fair_value]
      matrix[stock.ticker][:fair_value] = fair_value.round(2)

      market_to_fair_value = (fair_value/current_price - 1) * 100
      matrix[stock.ticker][:market_to_fair_value] = 0 unless matrix[stock.ticker][:market_to_fair_value]
      matrix[stock.ticker][:market_to_fair_value] = market_to_fair_value.round(2)

    end
    end_time = Time.now
    puts "Calc time: "+(end_time - start_time).to_s

    sort_by = :market_to_fair_value
    sorted = matrix.sort {|x,y| y[1][sort_by] <=> x[1][sort_by]}

    rjust = 14
    puts "ticker " + matrix.first[1].keys.map{|x| x.to_s.rjust(rjust)}.join(',')
    sorted.each_with_index do |row, index|
      puts row[0] + ' ' + row[1].values.map{|x| x.to_s.rjust(rjust)}.join(',')
      break if index > 20
    end
    end_time = Time.now
    puts end_time - start_time
    return nil;

  end

  def self.discount(p, d, y)
    sum = 0
    y.times do |year|
      sum += p/(1 + d/100.0) ** (year + 1)
    end

    return sum
  end

end
