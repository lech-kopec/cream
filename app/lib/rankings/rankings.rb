module Rankings

  def Rankings.ranking_2
    results = {}
    Stock.with_pisbs.each do |stock|
      results.store(stock.ticker, [stock.price_to_fair_value, stock])
    end

    sorted = results.sort_by { |key, value| value }
    sorted.each do |arr|
      if arr[1][0] > 0
        puts "#{arr[0]} : #{arr[1][0]} : #{arr[1][1].comment}"
      end
    end

    return sorted
  end

end
