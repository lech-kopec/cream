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
    matrix = []
    header = ["ticker", "cash", "liabilities", "market_cap", 'net_profit_sum', "nlc", "nlcPmc", "years_to_repay", "years_to_mc", "fair_value", 'market_to_fair_value']
    Stock.not_banks.all.each do |stock|
      unless stock.prices.latest.present?
        #puts "Skipping: ", stock.ticker
        next
      end

      net_profit_sum = stock.income_statements.where("year >= 2015").select("coalesce(sum(net_profit),0) as net_p_sum")[0].net_p_sum
      liabilities = stock.balance_sheets.where("year = 2017").select("coalesce(short_term_liabilities,0) as stl, coalesce(long_term_liabilities,0) as ltl")[0]
      unless liabilities.present?
        liabilities = stock.balance_sheets.where("year = 2016").select("coalesce(short_term_liabilities,0) as stl, coalesce(long_term_liabilities,0) as ltl")[0]
      end
      unless liabilities.present?
        puts "Skippingm, no liabilities: " + stock.ticker
        next
      end
      liabilities = liabilities.ltl + liabilities.stl
      cash = stock.balance_sheets.order(year: :desc).select("coalesce(cash,0) as cash")[0].cash
      current_price = stock.prices.latest.close
      market_cap = (stock.shares * current_price) / 1000
      nlc = net_profit_sum.to_d - liabilities.to_d + cash.to_d
      nlcPmc = market_cap / nlc
      average_year = net_profit_sum / 3
      years_to_repay = (liabilities - cash ) / average_year
      years_to_mc = years_to_repay + ( market_cap / average_year )
      fair_value = (Stock.discount(average_year, 6, 10) + cash - liabilities) / (stock.shares/1000)
      market_to_fair_value = (fair_value/current_price - 1) * 100
      matrix.push [stock.ticker, cash, liabilities, market_cap, net_profit_sum.round(2), nlc.round(2), nlcPmc.round(2), years_to_repay.round(2), years_to_mc.round(2), fair_value.round(2), market_to_fair_value.round(2)]
    end

    sort_by = -1
    rjust = 12
    matrix.sort! {|x,y| y[sort_by] <=> x[sort_by]}

    header.map! {|x| x.rjust(rjust)}
    puts header.join(',')
    counter = 0
    matrix.each_with_index do |row, index|
      if row[-5] > 0
        row.map! {|x| x.to_s.rjust(rjust)}
        puts row.join(',')
        counter += 1
        break if counter > 40
      end
    end
    return nil

  end

  def self.discount(p, d, y)
    sum = 0
    y.times do |year|
      sum += p/(1 + d/100.0) ** (year + 1)
    end

    return sum
  end

end
