module StockFrames
  module Strategies
    class S5 < StockFrames::Strategies::Base

      def pre_algo
      end

      def algo(report_year: 2018)
        #year_index = report_year - 2019
        year_index = @sf.year.find_index(report_year)
        return nil if (@sf.rating != nil && @sf.rating < 0)

        indicators = ::StockFrames::Indicators::YearlyIndicators.new(@sf, report_year)


        price_after_one_year =  @sf.prices[report_year+1][1]
        price_change = price_after_one_year - @sf.price_on_report_date[year_index] 

        hash = {
          ticker: @sf.ticker,
          price_change: price_change,
          roa: indicators.roa,
          altman: indicators.altman,
          piotroski: indicators.piotroski,
          gross_margin: indicators.sales_margin,
          price_to_revenue: indicators.price_to_revenue,
          price_to_operating_protif: indicators.price_to_operating_protif,
          ev_to_revenue: indicators.ev_to_revenue,
          ev_to_ebit: indicators.ev_to_ebit,
          ev_to_net_profit: indicators.ev_to_net_profit,
          ev_to_operating_cash_flow: indicators.ev_to_operating_cash_flow,
          ev_to_net_cash_flow: indicators.ev_to_net_cash_flow,
          ev_to_free_cash_flow: indicators.ev_to_free_cash_flow,
          sales_margin: indicators.sales_margin,
          operating_margin: indicators.operating_margin,
          ebit_margin: indicators.ebit_margin,
          net_margin: indicators.net_margin,
          roic: indicators.roic
        }
        return hash

      end

      def algo_backtest(results)
        return reults.select(&:present?).sort_by { |x| x[:price_change] }
      end
    end
  end
end
