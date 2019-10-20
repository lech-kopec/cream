module StockFrames
  module Strategies
    class Dcf_01 < StockFrames::Strategies::Base

      @@discount_rate = 10 / 100.0
      @@pln_bond = 2.85 / 100

      def dcf(report_year: 2018)
        year_index = report_year - 2019
        return nil if (year_index - 1) <= (@sf.year.count * (-1))
        average_fcf = (free_cash_flow(year_index) + free_cash_flow(year_index - 1) ) / 2
        average_net_profit = (@sf.net_profit[year_index] + @sf.net_profit[year_index - 1]  ) / 2
        avg = ( average_fcf + average_net_profit ) / 2
        avg = average_fcf
        byebug
        next_cash_flows = []
        10.times do |i|
          next_cash_flows.push avg
        end

        _npv = npv(next_cash_flows, @@discount_rate)

        _terminal_value = terminal_value _npv.last, @@pln_bond, @@discount_rate
        present_value_of_terminal_value = _terminal_value / ((1 + @@discount_rate)** 10)

        equity_value = _npv.reduce(0, :+) + present_value_of_terminal_value
        equity_value += cash_like(year_index) - debt(year_index)
        equity_per_share = equity_value / (@sf.shares)

        current_discount = (equity_per_share - @sf.price_on_report_date[year_index]) / @sf.price_on_report_date[year_index]
        current_discount *= 100
        byebug
        return nil if equity_per_share < 0.0 || current_discount < 0.0

        return [@sf.ticker, equity_per_share, current_discount, @sf.price_on_report_date.last]
      end

      def dcf_backtest(arr)
        success = 0.0
        rows = 0.0
        arr.each do |row|
          next unless row
          if row[1] < row[-1]
            success += 1.0
          end
          rows += 1.0
        end
        #return ["Success Rate: #{(success / rows).round(3) * 100}%"]
        return arr
      end

      def cash_like(i)
        (@sf.intangible[i] * 0.1 ) +
          (@sf.ppe[i] * 0.4 ) +
          (@sf.short_term_receivables[i] * 0.7) +
          (@sf.long_term_investments[i] * 0.5) +
          @sf.short_term_investments[i]
      end
      def debt(i)
        @sf.long_term_liabilities[i] + @sf.short_term_liabilities[i]
      end

      def score

      end

    end
  end
end
