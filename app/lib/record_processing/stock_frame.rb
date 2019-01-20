module RecordProcessing

  def self.import_from_active_record(records)
    hash = {}

    array_columns = BalanceSheet.column_names.concat(IncomeStatement.column_names).uniq! - ['id']

    records.each do |record|
      if hash[record.ticker]
        array_columns.each do |cl|
          hash[record.ticker][cl].push( record[cl] || 0.0 )
        end
      else
        hash[record.ticker] = {}
        Stock.column_names.each do |cl|
          hash[record.ticker][cl] = record[cl]
        end
        array_columns.each do |cl|
          hash[record.ticker][cl] = [ record[cl] || 0.0 ]
        end
      end
    end

    results = []
    hash.each_pair do |key, value|
      results.push ::RecordProcessing::StockFrame.new(value)
    end
    return results
  end

  class StockFrame

    def initialize(hash)
      @data = {}
      hash.each_pair do |key, value|
        if value.is_a? Array
          @data[key] = value
        else
          @data[key] = value
        end
      end
    end

    def method_missing(m, *args, &block)

      key = m.to_s

      if @data[key]
        if @data[key].is_a? Array
          return @data[key]
        else
          return @data[key]
        end
      end
    end

    def id
      return @data["stock_id"][0]
    end

    def attach_prices!(prices)
      @data["close"] = prices.map(&:close)
    end

    def add_property(key, value)
      @data[key] = value
    end

    def growth_on(prop)
      result = (@data[prop].last / @data[prop].first)
      result = result.to_r.to_d(10) + 0.0001 rescue 0.0001
      return result
    end

  end

end

#
#id                             | 439
#ticker                         | 01C
#name                           | 01CYBATON
#shares                         | 119666520.0
#year                           | 2014
#quarter                        | 
#revenue                        | 5835.0
#cost_of_revenue                | 5029.0
#selling_cost                   | 0.0
#administrative_cost            | 0.0
#gross_profit                   | 806.0
#other_operating_income         | 0.0
#other_operating_cost           | 0.0
#operating_protif               | 806.0
#financial_income               | 150.0
#financial_cost                 | 32.0
#other_income                   | 0.0
#income_before_tax              | 924.0
#extra_item                     | 0.0
#net_profit                     | 924.0
#stock_id                       | 439
#id                             | 14015
#year                           | 2014
#quarter                        | 
#fixed_assets                   | 53006.0
#intangible                     | 289.0
#ppe                            | 50704.0
#long_term_receivables          | 0.0
#long_term_investments          | 2013.0
#other_fixed_assets             | 0.0
#assets                         | 5362.0
#reserves                       | 42.0
#short_term_receivables         | 843.0
#short_term_investments         | 421.0
#cash                           | 421.0
#other_assets                   | 4056.0
#equity_capital                 | 52346.0
#basic_capital                  | 35867.0
#reserve_fund                   | 5738.0
#long_term_liabilities          | 0.0
#deliveries_services            | 
#credits_loans                  | 
#debt_securities                | 
#leasing                        | 
#other_long_terml_liabilities   | 0.0
#short_term_liabilities         | 6022.0
#short_term_deliveries_services | 230.0
#short_term_credit_loans        | 354.0
#short_term_debt_securities     | 0.0
#short_term_leasing             | 279.0
#other_short_term_liabilies     | 5159.0
#accrued_expenses               | 0.0
#stock_id                       | 439
#id                             | 1279271
#open                           | 0.05
#close                          | 0.04
#high                           | 0.05
#low                            | 0.04
#volume                         | 4021.0
#time                           | 2018-05-11 00:00:00
#stock_id                       | 439
#
