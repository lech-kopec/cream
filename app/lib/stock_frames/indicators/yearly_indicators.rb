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

      def ev(i = @index)
        return (
          market_cap + 
          @stock_frame.long_term_liabilities[i] +
          @stock_frame.short_term_liabilities[i] - 
          @stock_frame.short_term_investments[i]
        )
      end

      def roa(i = @index)
        result = @stock_frame.net_profit[i] / (
          @stock_frame.assets[i] + @stock_frame.fixed_assets[i] )
        return ::StockFrames::Indicators.safe_zero(result) * 100
      end

      def altman(i = @index)
        #Z-Score = 1.2A + 1.4B + 3.3C + 0.6D + 1.0E 
        #A = working capital / total assets
        #B = retained earnings / total assets
        #C = earnings before interest and tax / total assets
        #D = market value of equity / total liabilities
        #E = sales / total assets

        total_assets = @stock_frame.assets[i]
        total_liabilities = @stock_frame.long_term_liabilities[i] +
                              @stock_frame.short_term_liabilities[i]
        a = working_capital / total_assets
        a = ::StockFrames::Indicators.safe_zero(a)
        b = @stock_frame.net_profit[i] / total_assets
        b = ::StockFrames::Indicators.safe_zero(b)
        c = @stock_frame.income_before_tax[i] / total_assets
        c = ::StockFrames::Indicators.safe_zero(c)
        d = market_cap / total_liabilities
        d = ::StockFrames::Indicators.safe_zero(d)
        e = @stock_frame.revenue[i] / total_assets
        e = ::StockFrames::Indicators.safe_zero(e)

        z_score = 1.2*a + 1.4*b + 3.3*c + 0.6*d + e
        return z_score.negative? ? 1 : z_score.clamp(1, 10)
      end

      def piotroski(i = @index)
        score = 0

        score += 1 if @stock_frame.net_profit[i] > 0
        score += 1 if roa > 0
        #score += 1 if @stock_frame.operating_cash_flow[i] > 0
        score += 1 if quality_of_earnings?

        score += 1 if decreased_leverage?
        score += 1 if current_ratio(i) > current_ratio(i - 1)
        
        score += 1 if gross_margin(i) > gross_margin(i - 1)
        score += 1 if asset_turnover_ratio(i) > asset_turnover_ratio(i - 1)

        return score
      end

      def working_capital(i = @index)
        return (@stock_frame.assets[i] -
          @stock_frame.long_term_liabilities[i] -
          @stock_frame.short_term_liabilities[i])
      end

      def market_cap(i = @index)
        return (@stock_frame.shares * @stock_frame.price_on_report_date[i])
      end

      def quality_of_earnings?
        #return @stock_frame.operating_cash_flow[@index] > @stock_frame.net_profit[@index]
        return true
      end

      def decreased_leverage?(i = @index)
        return (long_term_leverage(i) < long_term_leverage(i - 1) )
      end

      def long_term_leverage(i = @index)
        return ::StockFrames::Indicators.safe_zero(
          @stock_frame.long_term_liabilities[i] / @stock_frame.assets[i]
        )
      end

      def current_ratio(i = @index)
        return ::StockFrames::Indicators.safe_zero(
           @stock_frame.short_term_investments[i] / (
            @stock_frame.long_term_liabilities[i] + 
            @stock_frame.short_term_liabilities[i]
          )
        )
      end

      def gross_margin(i = @index)
        return ::StockFrames::Indicators.safe_zero(
          @stock_frame.gross_profit[i] / @stock_frame.revenue[i]
        )
      end

      def asset_turnover_ratio(i = @index)
        return ::StockFrames::Indicators.safe_zero(
          @stock_frame.revenue[i] / @stock_frame.assets[i]
        )
      end

      def book_value(i = @index)
        return (@stock_frame.fixed_assets[i] + @stock_frame.assets[i]) -
          (@stock_frame.long_term_liabilities[i] + @stock_frame.short_term_liabilities[i])
      end

      def price_to_book_value(i = @index)
        book_value_per_share = book_value / @stock_frame.shares

        return @stock_frame.price_on_report_date[i] / book_value_per_share
      end

      def price_to_revenue(i = @index)
        return @stock_frame.price_on_report_date[i] / 
          (@stock_frame.revenue[i] / @stock_frame.shares)
      end

      def price_to_operating_protif(i = @index)
        return (@stock_frame.price_on_report_date[i]) /
          (@stock_frame.operating_protif[i] / @stock_frame.shares)
      end

      def ev_to_revenue(i = @index)
        return ev / @stock_frame.revenue[i]
      end

      def ev_to_ebit(i = @index)
        return ev / @stock_frame.operating_protif[i]

      end

      def ev_to_net_profit(i = @index)
        return ev / @stock_frame.net_profit[i]
      end

      def ev_to_operating_cash_flow( i = @index )
        return ev / @stock_frame.operating_cash_flow[i]
      end

      def ev_to_net_cash_flow(i = @index)
        return ev / @stock_frame.total_cash_flow[i]
      end

      def ev_to_free_cash_flow(i = @index)
        return ev / (
          @stock_frame.operating_cash_flow[i] -
          @stock_frame.capex[i]
        )
      end

      def sales_margin(i = @index)
        return (@stock_frame.gross_profit[i] / @stock_frame.revenue[i] ) * 100
      end

      def operating_margin(i = @index)
        return (@stock_frame.operating_protif[i] / @stock_frame.revenue[i]) * 100
      end

      def ebit_margin(i = @index)
        return (@stock_frame.income_before_tax[i] / @stock_frame.revenue[i]) * 100
      end

      def net_margin(i = @index)
        return (@stock_frame.net_profit[i] / @stock_frame.revenue[i]) * 100
      end

      def roic(i = @index)
        return @stock_frame.net_profit[i] / 
          (@stock_frame.basic_capital[i] + 
           @stock_frame.credits_loans[i] +
           @stock_frame.debt_securities[i] -
           @stock_frame.short_term_investments[i])
      end

      #======================================================
      # multi year average

      def roa_tavg(years_count, index = @index)
        return years_count.times.map { |i|
          roa(index - i)
        }.sum / years_count
      end

      def gross_margin_tavg(years_count, index = @index)
        return years_count.times.map { |i|
          gross_margin(index - i)
        }.sum / years_count
      end

      def price_to_book_value_tavg(years_count, index = @index)
        return years_count.times.map { |i|
          price_to_book_value(index - i)
        }.sum / years_count
      end

      def price_to_revenue_tavg(years_count, index = @index)
        return years_count.times.map { |i|
          price_to_revenue(index - i)
        }.sum / years_count
      end

      def price_to_operating_protif_tavg(years_count, index = @index)
        return years_count.times.map { |i|
          price_to_operating_protif(index - i)
        }.sum / years_count
      end

      def ev_to_revenue_tavg(years_count, index = @index)
        return years_count.times.map { |i|
          ev_to_revenue(index - i)
        }.sum / years_count
      end

      def ev_to_ebit_tavg(years_count, index = @index)
        return years_count.times.map { |i|
          ev_to_ebit(index - i)
        }.sum / years_count
      end

      def ev_to_net_profit_tavg(years_count, index = @index)
        return years_count.times.map { |i|
          ev_to_net_profit(index - i)
        }.sum / years_count
      end

      def ev_to_operating_cash_flow_tavg(years_count, index = @index)
        return years_count.times.map { |i|
          ev_to_operating_cash_flow(index - i)
        }.sum / years_count
      end

      def ev_to_net_cash_flow_tavg(years_count, index = @index)
        return years_count.times.map { |i|
          ev_to_net_cash_flow(index - i)
        }.sum / years_count
      end

      def ev_to_free_cash_flow_tavg(years_count, index = @index)
        return years_count.times.map { |i|
          ev_to_free_cash_flow(index - i)
        }.sum / years_count
      end

      def sales_margin_tavg(years_count, index = @index)
        return years_count.times.map { |i|
          sales_margin(index - i)
        }.sum / years_count
      end

      def operating_margin_tavg(years_count, index = @index)
        return years_count.times.map { |i|
          operating_margin(index - i)
        }.sum / years_count
      end

      def ebit_margin_tavg(years_count, index = @index)
        return years_count.times.map { |i|
          ebit_margin(index - i)
        }.sum / years_count
      end

      def net_margin_tavg(years_count, index = @index)
        return years_count.times.map { |i|
          net_margin(index - i)
        }.sum / years_count
      end

      def roic_tavg(years_count, index = @index)
        return years_count.times.map { |i|
          roic(index - i)
        }.sum / years_count
      end

      def altman_tavg(years_count, index = @index)
        return years_count.times.map { |i|
          altman(index - i)
        }.sum / years_count
      end
      
      def piotroski_tavg(years_count, index = @index)
        return years_count.times.map { |i|
          piotroski(index - i)
        }.sum / years_count
      end

    end
  end

end
