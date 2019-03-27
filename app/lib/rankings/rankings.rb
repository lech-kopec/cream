module Rankings

  def Rankings.ranking_2
    results = {}
    start_time = Time.now
    Stock.with_pisbs.each do |stock|
      stock.preload
      results.store(stock.ticker, [stock.price_to_fair_value, stock])
    end

    puts "Calc Time: #{Time.now - start_time}"

    sorted = results.sort_by { |key, value| value }
    sorted.each do |arr|
      if arr[1][0] > 0
        puts "#{arr[0]} : #{arr[1][0]} : #{arr[1][1].comment} : #{arr[1][1].rating}"
      end
    end

    return sorted
  end

end
