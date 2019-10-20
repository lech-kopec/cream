module StockFrames
  module Strategies
    class S4 < StockFrames::Strategies::Base

      def pre_algo
      end
      def algo(report_year: 2018)
        year_index = report_year - 2019
        return nil if (year_index - 2) <= (@sf.year.count * (-1))
        return nil if (@sf.rating != nil && @sf.rating < 0)
        return nil if @sf.price_on_report_date[year_index] < 0.2

        revenue_change = @sf.revenue[year_index] / calc_avg_prop('revenue', year_index, 3)
        net_profit_change = @sf.net_profit[year_index] / calc_avg_prop('net_profit', year_index, 3)
        #avg_ffc = (free_cash_flow_(year_index) + free_cash_flow_(year_index-1) + free_cash_flow_(year_index-2))/3
        #avg_ffc = 0.0
        #3.times do |i|
          #avg_ffc += (@sf.operating_cash_flow[year_index-i] - @sf.amortization[year_index-i])
        #end
        #avg_ffc = avg_ffc / 3

        avg_ffc = calc_avg_prop('net_profit', year_index, 3) * (revenue_change + net_profit_change)/2
        
        future_profit = avg_ffc

        market_cap = @sf.shares * @sf.price_on_report_date[year_index]
        _debt = debt(year_index)
        _cash = cash_like(year_index)
        _operating_margin = @sf.gross_profit[year_index] / @sf.revenue[year_index]

        enterprice_value = market_cap + _debt - _cash

        score = enterprice_value / future_profit

        #return nil if _debt > (market_cap * 0.5)
        return nil if future_profit < 100.0
        return nil if _debt > (_cash )
        return nil if _operating_margin < 0.01

        _price = @sf.price_on_report_date[year_index]

        _year_later = year_index + 1 <= -1 ? @sf.price_on_report_date[year_index + 1] : _price
        _change = ((_year_later / _price) - 1) * 100
        _latest_price = @sf.price_on_report_date[-1]
        _change2 = ((_latest_price / _price) - 1)

        #return [@sf.ticker, score.r2, future_profit.r2, market_cap.r2, _debt.r2, _cash.r2, _price.r2, _year_later.r2, _change.r2, _change2.r2]
        return { 
          ticker: @sf.ticker,
          score: score.r2,
          future_profit: future_profit.r2,
          market_cap: market_cap.r2,
          debt: _debt.r2,
          cash: _cash.r2,
          price:_price.r2,
          comment: @sf.comment
        }
      end

      def algo_backtest(arr)

        results = arr.sort_by {|row| !!row ? row[:score] : 0.0}
        return ['ticker, score, future_profit, market_cap, debt, cash, price'] + results.map {|row| !!row ? row.values : nil}
      end

    end
  end
end
