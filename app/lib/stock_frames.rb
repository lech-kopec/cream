module StockFrames
  def self.process_fields(record, hash = {} )
      is_columns = IncomeStatement.column_names - ['id'] - ['quarter']
      bs_columns = BalanceSheet.column_names - ['id'] - ['quarter']
      cf_columns = CashFlow.column_names - ['id'] - ['quarter']

      ticker = record.ticker
      hash[record.ticker] = {}
      is_columns.each do |cl|
        hash[ticker][cl] = []
        hash[ticker][cl+"_q"] = []
      end
      bs_columns.each do |cl|
        hash[ticker][cl] = []
        hash[ticker][cl+"_q"] = []
      end
      cf_columns.each do |cl|
        hash[ticker][cl] = []
        hash[ticker][cl+"_q"] = []
      end
      Stock.column_names.each do |cl|
        hash[record.ticker][cl] = record[cl]
      end
      record.income_statements.each{ |row|
        is_columns.each do |cl|
          value = row[cl] || 0.0
          row.quarter ? hash[ticker]["#{cl}_q"].push(value) : hash[ticker][cl].push(value)
        end
      }
      record.balance_sheets.each{ |row|
        bs_columns.each do |cl|
          next if cl == 'year'
          value = row[cl] || 0.0
          row.quarter ? hash[ticker]["#{cl}_q"].push(value) : hash[ticker][cl].push(value)
        end
      }
      record.cash_flows.each{ |row|
        cf_columns.each do |cl|
          next if cl == 'year'
          value = row[cl] || 0.0
          row.quarter ? hash[ticker]["#{cl}_q"].push(value) : hash[ticker][cl].push(value)
        end
      }
      return hash
  end

  def self.stock_frames_from_relations(records)
    start_year = 2010
    hashMap = {}
    records = records.
            includes(:income_statements, :balance_sheets, :cash_flows).
            references(:income_statements).
            references(:balance_sheets).
            references(:cash_flows).
            where("balance_sheets.year > #{start_year} and 
                  income_statements.year > #{start_year} and
                  cash_flows.year > #{start_year} and
                  income_statements.quarter is null and
                  balance_sheets.quarter is null and
                  cash_flows.quarter is null and
                  income_statements.year = balance_sheets.year and
                  cash_flows.year = income_statements.year").
            order("ticker").
            order("income_statements.year asc").
            order("balance_sheets.year asc").
            order("cash_flows.year asc")

    records.each do |record|
      StockFrames.process_fields(record, hashMap)
    end

    return hashMap.map do |key, value|
      ::StockFrames::Frame.new(value)
    end
  end

  def self.stock_frames_from_active_record(records)
    hash = {}

    array_columns = BalanceSheet.
                      column_names.
                      concat(IncomeStatement.column_names).
                      concat(CashFlow.column_names).
                      uniq! - ['id']

    #records.each do |record|
    records.find_each(batch_size: 10).each do |record|
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
      results.push ::StockFrames::Frame.new(value)
    end
    return results
  end


end
