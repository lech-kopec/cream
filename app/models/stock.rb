class Stock < ApplicationRecord
  enum status: [ :active, :restructuring, :bankrupcy, :removed ]

  @@backtesting_year = 2016
  #ActiveRecord::Base.logger = nil

  belongs_to :market
  belongs_to :sector

  has_many :income_statements, dependent: :destroy
  has_many :balance_sheets, dependent: :destroy
  has_many :cash_flows, dependent: :destroy
  has_many :prices, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  scope :not_banks, lambda { 
    id = Sector.find_by_name('Banks')
    where("sector_id != ?", id)
  }

  scope :not_having_is, lambda { |year, quarter|
    Stock.where("id not in (select stock_id from income_statements
                 where year = #{year} and quarter = #{quarter} )") 
  }

  scope :not_having_is_year, lambda { |year|
    Stock.where("id not in (select stock_id from income_statements
                 where year = #{year} and quarter is null)") 
  }

  scope :not_having_bs, lambda { |year, quarter|
    Stock.where("id not in (select stock_id from balance_sheets
                 where year = #{year} and quarter = #{quarter} )") 
  }

  scope :not_having_cf, lambda { |year, quarter|
    Stock.where("id not in (select stock_id from cash_flows
                 where year = #{year} and quarter = #{quarter} )") 
  }

  scope :with_pisbs, lambda {
      Stock.find_by_sql("
                    select * from stocks where id in 
                      (select distinct stock_id from balance_sheets where year = 2018 and quarter = 1 INTERSECT
                      select distinct stock_id from income_statements INTERSECT
                      select distinct stock_id from prices)
                  ") }

  #def income_quarters
    #return self.income_statements.
                  #where("year <= #{@@backtesting_year}").
                  #where("quarter is not null")
  #end

  #def self.find_prices_on_yearly_reports(stock_ids, years)

    #where_stm = []
    #years.each do |year|
      #where_stm.push( "(time > '#{year + 1}-03-10' and time < '#{year + 1}-03-15')")
    #end

    #return Price.
                #select("max(time) as time,
                       #max(close) as close,
                       #date_part('year', time) as year,
                       #stock_id").
                #where("stock_id in (#{stock_ids.join(',')})").
                #where(where_stm.join(' OR ')).
                #order("time").
                #group("stock_id", "year")
  #end

  #def self.discount(p, d, y)
    #sum = 0
    #y.times do |year|
      #sum += p/(1 + d/100.0) ** (year + 1)
    #end

    #return sum
  #end

  #def net_profit_last_4_quarters
    #values = income_statements.
                #where("year <= #{@@backtesting_year}").
                #where.not(quarter: nil).
                #order(year: :desc).order(quarter: :desc).
                #limit(4).
                #map do |is|
                  #is.net_profit ? is.net_profit : 0.0
                #end

    #return values.sum
  #end

  #def average_net_profit_yearly(num_years)
    #values = income_statements.
                #where(quarter: nil).
                #where("year <= #{@@backtesting_year}").
                #order(year: :desc).
                #limit(num_years).map do |is|
                  #is.net_profit ? is.net_profit : 0.0
                #end
    #return values.sum / num_years
  #end

  #def latest_balance_sheet
    #@balance_sheets_quarterly ||= balance_sheets.
                                    #where("year <= #{@@backtesting_year}").
                                    #order(year: :desc).
                                    #order(quarter: :desc).
                                    #first
  #end

  #def latest_cash
    #latest_balance_sheet.cash
  #end

  #def latest_cash_like
    #(latest_balance_sheet.intangible * 0.1 ) +
    #(latest_balance_sheet.ppe * 0.4 ) +
    #(latest_balance_sheet.short_term_receivables * 0.7) +
    #(latest_balance_sheet.long_term_investments * 0.5) +
    #latest_balance_sheet.short_term_investments
  #end

  #def latest_debt
    #latest_balance_sheet.long_term_liabilities + latest_balance_sheet.short_term_liabilities
  #end

  #def latest_price
    #values = prices.where("time < '2017-03-21'").order(time: :desc)
    #return -0.0000001 unless values.first
    #return values.first.close
  #end

  #def market_cap
    #shares * latest_price
  #end


  #def fair_value
    #fair_value_combine_data.first.second.to_s
  #end

  #def future_profit
    #values = income_statements.
                #where("year <= 2016").
                #where("quarter is null").
                #order(year: :desc).
                #limit(3).map do |is|
                  #is.net_profit ? is.net_profit : 0.0
                #end
    #revenues = income_statements.
                #where("year <= 2017").
                #where("quarter is null").
                #order(year: :desc).
                #limit(3).map do |is|
                  #is.revenue ? is.revenue + 0.00001 : 0.00001
                #end
    #average_profit = (values.sum + net_profit_last_4_quarters ) / 4

    ##profit_change = net_profit_last_4_quarters / average_profit
    #revenue_change = revenues[0] / revenues[-1]

    #return (average_profit * (((revenue_change-1)/2) + 1))
    ##return average_net_profit_yearly(3)
  #end

  #def fair_value_combine_data
    #year_into_future = 10

    #dcf = Stock.discount(future_profit, 5, year_into_future)
    #cash_like = latest_cash_like
    #debt = latest_debt

    #ev = dcf + cash_like - debt

    #target_value = ev / (shares/1000)

    #return {
      #fair_value: target_value,
      #future_profit: future_profit,
      #cash: cash_like,
      #debt: debt,
      #market_cap: (market_cap / 1000)
    #}
  #end

  #def price_to_fair_value
    #(latest_price / fair_value_combine_data[:fair_value]).round(2)
  #end

end

