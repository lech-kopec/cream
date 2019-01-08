require_dependency '../lib/stock_frame_indicators/indicators.rb'

class ScoringModel

  # input - [stock_frame]
  def self.t1(sf)
    # ev, altman, piotroski
    MAIN_YEAR_INDEX = -1
    indicators = YearlyIndicators.new(sf, sf.year[MAIN_YEAR_INDEX])
    ev = indicators.ev
    net_profit = sf.net_profit[MAIN_YEAR_INDEX]
    ptr = indicators.piotroski
    altman = indicators.altman

    score = (ev/net_profit) / (altman + ptr)
  end

end
