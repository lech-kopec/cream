require_dependency '../lib/stock_frame_indicators/indicators.rb'

class ScoringModel

  SMALL = 0.00001
  ALTMAN_COEF = 1
  PTR_COEF = 1
  REVENUE_GR_COEF = 1
  NET_PROFIT_GR_COEF = 1

  # input - [stock_frame]
  def self.t1(stock_frames)
    # ev, altman, piotroski
    main_year_index = -1

    scored_frames = {}
    stock_frames.each do |sf|
      indicators = ::StockFramesIndicators::YearlyIndicators.new(sf, sf.year[main_year_index])

      net_profit = sf.net_profit.sum / sf.net_profit.length
      net_profit = net_profit*0.8 + sf.net_profit.last


      piotroski = indicators.piotroski
      ptr = piotroski > 6 ? piotroski : SMALL
      ptr *= PTR_COEF

      altman = indicators.altman * ALTMAN_COEF - 5

      ev = indicators.ev
      income_speed = ev/net_profit
      income_speed = income_speed > 20 ? income_speed ** 2 : income_speed

      sf.add_property 'income_speed', income_speed

      revenue_growth = sf.growth_on 'revenue' 
      revenue_growth **= REVENUE_GR_COEF

      net_profit_growth = sf.growth_on 'net_profit'
      net_profit_growth **= NET_PROFIT_GR_COEF

      sf.add_property 'revenue_growth', revenue_growth
      sf.add_property 'net_profit_growth', net_profit_growth
      sf.add_property 'altman', altman
      sf.add_property 'ptr', ptr

      score = income_speed / (altman * ptr * revenue_growth * net_profit_growth).to_f
      #score = income_speed / (altman * ptr).to_f
      score = score.round(4)

      if income_speed < 0 || altman < 0 || revenue_growth < 0 || net_profit_growth < 0
        score = score.abs * (-1)
      end

      #binding.irb if sf.ticker == 'RWD'

      scored_frames[sf.ticker] = [score, sf]
    end

    return scored_frames.sort_by{|k,v| v[0]}.to_h
  end

end
