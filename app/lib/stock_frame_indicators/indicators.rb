module StockFramesIndicators
  # operating on stock frames

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
      @stock_frame.net_profit[@index] / @stock_frame.assets[@index]
    end

    def altman
      #Z-Score = 1.2A + 1.4B + 3.3C + 0.6D + 1.0E 
      #A = working capital / total assets
      #B = retained earnings / total assets
      #C = earnings before interest and tax / total assets
      #D = market value of equity / total liabilities
      #E = sales / total assets

    end

    def piotroski
      score = 0

      score += 1 if @stock_frame.net_profit[@index] > 0
      score += 1 if return_on_assets > 0
      score += 1 if @stock_frame.operating_cash_flow[@index] > 0
      score += 1 if quality_of_earnings?

      score += 1 if decreased_leverage?
      score += 1 if current_ratio(@index) > current_ratio(@index - 1)
      
      score += 1 if gross_margin(@index) > gross_margin(@index - 1)
      score += 1 if asset_turnover_ratio(@index) > asset_turnover_ratio(@index - 1)

    end

    def market_cap
      @stock_frame.shares * @stock_frame.close[@index]
    end

    def quality_of_earnings?
      return @stock_frame.operating_cash_flow[@index] > @stock_frame.net_profit[@index]
    end

    def decreased_leverage?
      return long_term_leverage(@index) < long_term_leverage(@index - 1)
    end

    def long_term_leverage(index)
      return @stock_frame.long_term_liabilities[index] / @stock_frame.assets[index]
    end

    def current_ratio(index)
      return @stock_frame.short_term_investments[index] / (
        @stock_frame.long_term_liabilities[index] + 
        @stock_frame.short_term_liabilities[index]
      )
    end

    def gross_margin(index)
      return @stock_frame.gross_profit[index] / @stock_frame.revenue[index]
    end

    def asset_turnover_ratio(index)
      return @stock_frame.revenue[index] / @stock_frame.assets[index]
    end

  end

end
