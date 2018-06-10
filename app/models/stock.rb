require_dependency '../lib/graphs/query_graph.rb'
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
    years_count = 3
    start_time = Time.now
    # row should contain
    # "ticker", "cash", "liabilities", "market_cap", 'net_profit_sum', EV, "years_to_repay", "avg_years_to_ev", "fair_value", 'market_to_fair_value' score
    matrix = {}
    results = Stock
        .not_banks
        .select("*")
        .joins(:income_statements)
        .joins(:balance_sheets)
        .joins("join prices on prices.id = (select id from prices where prices.stock_id = stocks.id order by time desc limit 1)")
        .where("balance_sheets.year = income_statements.year")
        .where("balance_sheets.year in (2015, 2016, 2017) and income_statements.year in (2015, 2016, 2017)")
        .order("ticker asc, balance_sheets.year desc")

    results.each do |stock|
      matrix[stock.ticker] = {} unless matrix[stock.ticker]

      obj = matrix[stock.ticker]

      obj[:net_profit_sum] = 0 unless obj[:net_profit_sum]
      obj[:net_profit_sum] += stock.net_profit.to_f.round(2)


      obj[:cash] = stock.cash.to_f.round(2) if stock.year == 2017

      obj[:liabilities] = (stock.short_term_liabilities.to_f + stock.long_term_liabilities.to_f + stock.accrued_expenses.to_f).round(2) if stock.year == 2017


      current_price = stock.close.round(2)
      if !current_price || !obj[:liabilities]
        matrix.delete stock.ticker
        next
      end

      market_cap = (stock.shares * current_price) / 1000
      obj[:market_cap] = market_cap.round(2)

      average_year = obj[:net_profit_sum] / years_count
      years_to_repay = (obj[:liabilities] - obj[:cash] ) / average_year
      obj[:years_to_repay] = 0 unless obj[:years_to_repay]
      obj[:years_to_repay] = years_to_repay.round(2)

      years_to_mc = years_to_repay + ( market_cap / average_year )
      obj[:years_to_mc] = 0 unless obj[:years_to_mc]
      obj[:years_to_mc] = years_to_mc.round(2)

      ev = market_cap + obj[:liabilities] - obj[:cash]
      years_to_ev = ev/average_year

      obj[:price] = current_price.round(2)

      fair_value = (Stock.discount(average_year, 6, 10) + obj[:cash] - obj[:liabilities]) / (stock.shares/1000)
      obj[:fair_value] = 0 unless obj[:fair_value]
      obj[:fair_value] = fair_value.round(2)

      market_to_fair_value = (fair_value/current_price - 1) * 100
      obj[:market_to_fair_value] = 0 unless obj[:market_to_fair_value]
      obj[:market_to_fair_value] = market_to_fair_value.round(2)

      obj[:years_to_ev] = years_to_ev.round(2)

    end
    end_time = Time.now
    puts "Calc time: "+(end_time - start_time).to_s

    sort_by = :market_to_fair_value
    sorted = matrix.sort {|x,y| y[1][sort_by] <=> x[1][sort_by]}

    rjust = 18
    puts "ticker: " + matrix.first[1].keys.map{|x| x.to_s.rjust(rjust)}.join(',')
    counter = 0
    sorted.each do |row|
      next if row[1][:net_profit_sum] <= 1.0 || row[1][:cash] == 0.0
      next if row[1][:market_to_fair_value] < 10
      puts row[0] + ': ' + row[1].values.map{|x| x.to_s.rjust(rjust)}.join(',')
      counter += 1
      break if counter > 50
    end
    end_time = Time.now
    puts end_time - start_time
    return nil;

  end

  def self.test3
    # "ticker", "cash", "liabilities", "market_cap", 'net_profit_sum', EV, "years_to_repay", "avg_years_to_ev", "fair_value", 'market_to_fair_value' score
    input = {
      nodes: {
        '1' => {type: "Collection", value: "Stock", selectors: [{scope: 'not_banks'}], output: ['3','4']},
        '6' => {type: "Resource", value: "BalanceSheet", output: [], selectors: [{year: 'in (2017)'}] },
        '7' => {type: "Resource", value: "IncomeStatement", output: [], selectors: [{year: 'in (2016, 2017)'}] },
        '8' => {type: "Resource", value: "BalanceSheet", output: [], selectors: [{cash: '> 0', year: 'in (2015)'}] },
        '3' => {type: "Attribute", value: "stocks.ticker", output: ['5'], inputs: ['1']},
        '4' => {type: "Attribute", value: "stocks.shares", output: ['5'], inputs: ['1']},
        '9' => {type: "Attribute", value: "balance_sheets.cash", output: ['5'], inputs: ['6']},
        '5' => {type: "Operation", value: "Print", output: [], inputs: ['3']},
      },
      edges: [
        { 1 => 2 },
        { 2 => 3 },
        { 2 => 4 },
      ]
    }

    query_graph = ::Graph::QueryGraph.new input

  end

  def self.discount(p, d, y)
    sum = 0
    y.times do |year|
      sum += p/(1 + d/100.0) ** (year + 1)
    end

    return sum
  end

end

