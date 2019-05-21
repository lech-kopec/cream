desc "Add prices to income statements"
task :add_prices_to_is => :environment do

  Stock.not_banks.active.each do |stock|
    stock.income_statements
      .where("quarter is null")
      .where("price_on_report_date = 0.0").each do |is|
        year = is.year + 1
        price = Price.find_by_sql(
          "select avg(close) from prices where stock_id = #{stock.id} and 
            time > '#{year}-02-01' and time < '#{year}-05-01'
          "
        ).first.avg
        is.price_on_report_date = price
        is.save!
        puts "Save is for stock: #{stock.ticker} : #{is.year}"
    end
  end
end
