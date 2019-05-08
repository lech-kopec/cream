module StockFrames
  module Strategies
    class Dcf_01

      def initialize stock_frames
        @sf = stock_frames
      end

      def free_cash_flow
        ebit = @sf.income_before_tax.last
        change_in_capital = @sf.working_capital(-1) - @sf.working_capital(-2)

        x = (ebit * (1 - 0.19)) + @sf.amortization.last - change_in_capital - @sf.capex.last

        return x
      end

      def score

      end

    end
  end
end
