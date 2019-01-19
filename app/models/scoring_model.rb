require_dependency '../lib/stock_frame_indicators/indicators.rb'

class ScoringModel

  SMALL = 0.00001

  # input - [stock_frame]
  def self.t1(stock_frames)
    # ev, altman, piotroski
    main_year_index = -1

    scored_frames = {}
    stocks_scored = {}
    stock_frames.each do |sf|
      indicators = ::StockFramesIndicators::YearlyIndicators.new(sf, sf.year[main_year_index])

      net_profit = sf.net_profit.sum / sf.net_profit.length
      net_profit = net_profit*0.5 + sf.net_profit.last


      piotroski = indicators.piotroski
      ptr = piotroski > 6 ? piotroski ** 2 : SMALL

      altman = indicators.altman

      ev = indicators.ev
      income_speed = ev/net_profit
      income_speed = income_speed > 20 ? income_speed ** 2 : income_speed



      sf.add_property 'income_speed', income_speed

      #revenue_growth = ( sf.revenue.last / sf.revenue.first ) * 100
      #revenue_growth = revenue_growth.to_r.to_d(10) + SMALL rescue SMALL
      revenue_growth = sf.growth_on 'revenue'

      #net_profit_growth = sf.net_profit.last / sf.net_profit.first * 100
      net_profit_growth = sf.growth_on 'net_profit'

      sf.add_property 'revenue_growth', revenue_growth

      score = income_speed / (altman * ptr * revenue_growth * net_profit_growth).to_f
      score = score.round(4)

      puts "score: #{score}: #{sf.ticker}"

      #binding.irb if sf.ticker == 'RWD'

      scored_frames[score] = sf
      stocks_scored[sf.ticker] = score
    end

    return scored_frames.sort.to_h, stocks_scored
  end

end
