module StockFrames
  module Indicators
    # operating on stock frames
    #
    def self.safe_zero(x)
      return x.to_r.to_d(10) rescue 0
    end

    class YearlyIndicators
      def initialize(sf, year)
        @stock_frame = sf
        @year = year
        @index = @stock_frame.year.index(year)
      end

      def ev
        # market_cap + debt - cash - long_term_investments
        return (
          market_cap + 
          @stock_frame.long_term_liabilities[@index] +
          @stock_frame.short_term_liabilities[@index] - 
          @stock_frame.cash[@index] -
          @stock_frame.long_term_investments[@index]
        )
      end

      def return_on_assets
        result = @stock_frame.net_profit[@index] / @stock_frame.assets[@index]
        return StockFramesIndicators.safe_zero(result)
      end

      def altman
        #Z-Score = 1.2A + 1.4B + 3.3C + 0.6D + 1.0E 
        #A = working capital / total assets
        #B = retained earnings / total assets
        #C = earnings before interest and tax / total assets
        #D = market value of equity / total liabilities
        #E = sales / total assets

        total_assets = @stock_frame.assets[@index]
        total_liabilities = @stock_frame.long_term_liabilities[@index] + @stock_frame.short_term_liabilities[@index]
        a = working_capital / total_assets
        a = StockFramesIndicators.safe_zero(a)
        b = @stock_frame.net_profit[@index] / total_assets
        b = StockFramesIndicators.safe_zero(b)
        c = @stock_frame.income_before_tax[@index] / total_assets
        c = StockFramesIndicators.safe_zero(c)
        d = market_cap / total_liabilities
        d = StockFramesIndicators.safe_zero(d)
        e = @stock_frame.revenue[@index] / total_assets
        e = StockFramesIndicators.safe_zero(e)

        z_score = 1.2*a + 1.4*b + 3.3*c + 0.6*d + e
        return z_score.negative? ? 1 : z_score
      end

      def piotroski
        score = 0

        score += 1 if @stock_frame.net_profit[@index] > 0
        score += 1 if return_on_assets > 0
        #score += 1 if @stock_frame.operating_cash_flow[@index] > 0
        score += 1 if quality_of_earnings?

        score += 1 if decreased_leverage?
        score += 1 if current_ratio(@index) > current_ratio(@index - 1)
        
        score += 1 if gross_margin(@index) > gross_margin(@index - 1)
        score += 1 if asset_turnover_ratio(@index) > asset_turnover_ratio(@index - 1)

        return score
      end

      def working_capital
        return (@stock_frame.assets[@index] -
          @stock_frame.long_term_liabilities[@index] -
          @stock_frame.short_term_liabilities[@index])
      end

      def market_cap
        return ((@stock_frame.shares * @stock_frame.close[@index]) / 1000)
      end

      def quality_of_earnings?
        #return @stock_frame.operating_cash_flow[@index] > @stock_frame.net_profit[@index]
        return true
      end

      def decreased_leverage?
        return (long_term_leverage(@index) < long_term_leverage(@index - 1) )
      end

      def long_term_leverage(index)
        return StockFramesIndicators.safe_zero(
          @stock_frame.long_term_liabilities[index] / @stock_frame.assets[index]
        )
      end

      def current_ratio(index)
        return StockFramesIndicators.safe_zero(
           @stock_frame.short_term_investments[index] / (
            @stock_frame.long_term_liabilities[index] + 
            @stock_frame.short_term_liabilities[index]
          )
        )
      end

      def gross_margin(index)
        return StockFramesIndicators.safe_zero(
          @stock_frame.gross_profit[index] / @stock_frame.revenue[index]
        )
      end

      def asset_turnover_ratio(index)
        return StockFramesIndicators.safe_zero(
          @stock_frame.revenue[index] / @stock_frame.assets[index]
        )
      end

    end
  end

end
