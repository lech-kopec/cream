module StockFrames
  module Strategies
    class S3 < StockFrames::Strategies::Base

      def pre_algo
        return "ticker, score, future_profit, market_cap, _debt, _cash, _price, _latest_price, change"
      end
      def algo(report_year: 2018)
        year_index = report_year - 2019
        return nil if (year_index - 1) <= (@sf.year.count * (-1))
        return nil if (@sf.rating != nil && @sf.rating < 0)
        return nil if @sf.price_on_report_date[year_index] == 0.0 || @sf.price_on_report_date[year_index] < 0.3

        
        average_net_profit = (@sf.net_profit[year_index] + @sf.net_profit[year_index-1] + @sf.net_profit[year_index-2] ) / 3
        return nil if average_net_profit < 250.0

        average_revenue = (@sf.revenue[year_index] + @sf.revenue[year_index-1] + @sf.revenue[year_index-2] ) / 3

        revenue_change = (@sf.revenue[year_index] / average_revenue )
        net_profit_change = @sf.net_profit[year_index-1] / average_net_profit

        future_profit = @sf.net_profit[year_index] * (net_profit_change + revenue_change)/2

        market_cap = @sf.shares * @sf.price_on_report_date[year_index]
        _debt = debt(year_index)
        _cash = cash_like(year_index)
        enterprice_value = market_cap + _debt - _cash


        if ( future_profit <= 250.0 || _debt > (market_cap*0.4) || _debt > (_cash * 0.8))
          return nil
        end

        score = enterprice_value / future_profit

        return nil if score > 20 || score < 0.0

        _price = @sf.price_on_report_date[year_index]
        _year_later = year_index + 1 <= -1 ? @sf.price_on_report_date[year_index + 1] : _price
        _change = ((_year_later / _price) - 1) * 100

        return [@sf.ticker, score, future_profit, market_cap, _debt, _cash, _price, _year_later, _change]
      end

      def algo_backtest(arr)
        success = 0.0
        rows = 0.0
        _change = 0
        arr.each do |row|
          next unless row
          next unless row.is_a? Array
          if row[-3] <= row[-2]
            success += 1.0
          end
          _change += row[-1]
          rows += 1.0
        end
        return ["Success Rate: #{(success / rows).round(3) * 100}%: Average Change: #{(_change / rows).round(3)}"]
      end

    end
  end
end
