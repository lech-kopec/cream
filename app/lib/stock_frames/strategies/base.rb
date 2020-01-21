module StockFrames
  module Strategies
    class Base
      @@discount_rate = 10 / 100.0
      @@pln_bond = 2.85 / 100

      def self.initialize_from_ticker ticker
        stock = Stock.where(ticker: ticker)
        return self.new(StockFrames.stock_frames_from_relations(stock))
      end

      def initialize stock_frames
        @frames = stock_frames
      end

      def frames
        return @frames
      end

      def pre_algo
      end
      def run(method, **args)
        results = []
        #results.push pre_algo
        results += @frames.map do |sf|
          @sf = sf
          begin
            self.send(method, **args)
          rescue TypeError => e
            puts "TypeErro: #{@sf.ticker} : #{e}"
            return nil
          rescue NoMethodError => e
            puts "Calc problem, probably no data for #{@sf.ticker} : #{e}"
          rescue FloatDomainError => e
            puts e
            puts @sf.ticker
            puts @sf
          rescue ArgumentError => e
            puts e
            puts @sf.ticker
            puts @sf
          end
        end
        if self.respond_to?(method.to_s+"_backtest")
          backtest_results = self.send(method.to_s+"_backtest", results)
        end
        return [results, backtest_results || nil]
      end

      def free_cash_flow_(i)
        index = i || -1
        ebit = @sf.operating_protif[index]
        change_in_capital = @sf.working_capital(index) - @sf.working_capital(index - 1)

        x = (ebit * (1 - 0.19)) + @sf.amortization[index] - change_in_capital - @sf.capex[index]

        return x
      end

      def free_cash_flow(i)
        index = i || -1
        ocf = @sf.operating_cash_flow[index]

        x = (ocf) - @sf.capex[index]

        return x
      end

      def npv(array, discount_rate)
        discounted = array.each_with_index.map do |value, i|
          value / ((1 + discount_rate) ** (i + 1))
        end
        return discounted
      end

      def terminal_value(x, risk_free, discount)
        return (x * (1 + (risk_free))) / ((discount - risk_free))
      end

      def calc_equity_value(next_cash_flows, year_index)
        _npv = npv(next_cash_flows, @@discount_rate)

        _terminal_value = terminal_value(_npv.last, @@pln_bond, @@discount_rate)
        present_value_of_terminal_value = _terminal_value / ((1 + @@discount_rate)** 10)

        equity_value = _npv.reduce(0, :+) + present_value_of_terminal_value
        equity_value += cash_like(year_index) - debt(year_index)
        return equity_value
      end

      def calc_equity_per_share(next_cash_flows, year_index)
        equity_value = calc_equity_value(next_cash_flows, year_index)
        return equity_value / (@sf.shares)
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

      def calc_avg_prop(prop, i, count)
        results = 0.0
        count.times do |j|
          results += @sf.send(prop)[i-j]
        end
        return results / count
      end

    end
  end
end
