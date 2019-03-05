module Rankings

  def Rankings.ranking_2
    results = {}
    Stock.not_banks.each do |stock|
      results.store(stock.ticker, stock.price_to_fair_value)
    end

    sorted = results.sort_by { |key, value| value }
    sorted.each do |arr|
      puts arr[0] + ": " + arr[1].to_s
    end

    return sorted
  end

end
