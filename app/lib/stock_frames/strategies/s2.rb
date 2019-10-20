module StockFrames
  module Strategies
    class S2 < StockFrames::Strategies::Base

      def algo(report_year: 2018)
        year_index = report_year - 2019
        return nil if (year_index - 1) <= (@sf.year.count * (-1))
        
        average_net_profit = (@sf.net_profit[year_index] + @sf.net_profit[year_index-1] + @sf.net_profit[year_index-2] ) / 3

        revenue_change = (@sf.revenue[year_index] / @sf.revenue[year_index-1] )

        avg = average_net_profit * revenue_change
        byebug
        next_cash_flows = []
        10.times do |i|
          next_cash_flows.push avg
        end

        equity_per_share = calc_equity_per_share(next_cash_flows, year_index)

        current_discount = (equity_per_share - @sf.price_on_report_date[year_index]) / @sf.price_on_report_date[year_index]
        current_discount *= 100
        byebug
        return nil if equity_per_share < 0.0 || current_discount < 0.0

        return [@sf.ticker, equity_per_share, current_discount, @sf.price_on_report_date.last]
      end

      def algo_backtest(arr)
        success = 0.0
        rows = 0.0
        arr.each do |row|
          next unless row
          if row[1] < row[-1]
            success += 1.0
          end
          rows += 1.0
        end
        return ["Success Rate: #{(success / rows).round(3) * 100}%"]
      end

    end
  end
end
