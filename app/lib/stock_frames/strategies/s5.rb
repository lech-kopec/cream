module StockFrames
  module Strategies
    class S5 < StockFrames::Strategies::Base

      TAVG = 3
      RANGE = 15.0

      def pre_algo
      end

      def algo(report_year: 2018)
          #year_index = report_year - 2019
          year_index = @sf.year.find_index(report_year)
          return nil if (@sf.rating != nil && @sf.rating < 0)

          indicators = ::StockFrames::Indicators::YearlyIndicators.new(@sf, report_year)

          if !@sf.prices || !@sf.prices[report_year+1] ||
              !@sf.prices[report_year+1][1] ||
              !@sf.prices[report_year+2] ||
              !@sf.prices[report_year+2][1]
            puts @sf.ticker + "No prices for #{report_year} + 2"
            return nil
          end
          price_after_one_year =  @sf.prices[report_year+2][1]
          price_change = ((
            price_after_one_year - @sf.prices[report_year+1][1]) /
            @sf.prices[report_year+1][1] ) * 100

          max_price_within_year = @sf.prices[report_year+2].values.max
          max_price_within_year = ((
            max_price_within_year - @sf.prices[report_year+1][1]) /
            @sf.prices[report_year+1][1] ) * 100

          max_price_2_year = @sf.prices[report_year+2].values.concat(
            @sf.prices[report_year+3].values
          ).max
          max_price_2_year = ((
            max_price_2_year - @sf.prices[report_year+1][1]) /
            @sf.prices[report_year+1][1] ) * 100


          hash = {
            ticker: @sf.ticker,
            price_change: price_change.round,
            max_price_within_year: max_price_within_year.clamp(-RANGE, RANGE).round,
            max_price_2_year: max_price_2_year.clamp(-RANGE, RANGE).round,
            #roa: indicators.roa_tavg(TAVG).clamp(-RANGE, RANGE).round,
            altman: indicators.altman.clamp(0, 5).round,
            #piotroski: indicators.piotroski_tavg(TAVG).clamp(-RANGE, RANGE).round,
            #gross_margin: indicators.gross_margin_tavg(TAVG).clamp(-RANGE, RANGE).round,
            #sales_margin: indicators.sales_margin_tavg(TAVG).clamp(-RANGE, RANGE).round,
            #operating_margin: indicators.operating_margin_tavg(TAVG).clamp(-RANGE, RANGE).round,
            #ebit_margin: indicators.ebit_margin_tavg(TAVG).clamp(-RANGE, RANGE).round,
            #net_margin: indicators.net_margin_tavg(TAVG).clamp(-RANGE, RANGE).round,
            #roic: indicators.roic_tavg(TAVG).clamp(-RANGE, RANGE).round,
            #price_to_revenue: indicators.price_to_revenue_tavg(TAVG).clamp(-RANGE, RANGE).round,
            #price_to_operating_protif: indicators.price_to_operating_protif_tavg(TAVG).clamp(-RANGE, RANGE).round,
            #ev_to_revenue: indicators.ev_to_revenue_tavg(TAVG).clamp(-RANGE, RANGE).round,
            #ev_to_ebit: indicators.ev_to_ebit_tavg(TAVG).clamp(-RANGE, RANGE).round,
            #ev_to_net_profit: indicators.ev_to_net_profit_tavg(TAVG).clamp(-RANGE, RANGE).round,
            #ev_to_operating_cash_flow: indicators.ev_to_operating_cash_flow_tavg(TAVG).clamp(-RANGE, RANGE).round,
            #ev_to_net_cash_flow: indicators.ev_to_net_cash_flow_tavg(TAVG).clamp(-RANGE, RANGE).round,
            #ev_to_free_cash_flow: indicators.ev_to_free_cash_flow_tavg(TAVG).clamp(-RANGE, RANGE).round,
          }
        return hash

      end

      def algo_backtest(results)
        return results.select(&:present?).sort_by { |x| x[:max_price_2_year] }
      end
    end
  end
end
