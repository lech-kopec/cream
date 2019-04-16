module Rankings

  def Rankings.ranking_2
    results = {}
    Stock.with_pisbs.each do |stock|
      next if stock.latest_price < 0.30
      next if stock.rating && stock.rating < 0
      next if (stock.market_cap / 1000) < stock.latest_debt
      fair_value_combine_data = stock.fair_value_combine_data
      #score = (stock.latest_price / fair_value_combine_data[:fair_value]).round(2)
      target_price = fair_value_combine_data[:fair_value].round(2)
      growth_potential = ( (target_price / stock.latest_price) - 1).round(2)
      results.store(stock.ticker, [target_price, growth_potential, stock, fair_value_combine_data])
    end

    file = File.open("./ranking", "w")
    file.truncate 0
    file.write "ticker , target_price , growth_potential , comment , rating , average_net_profit_yearly(3) , cash-debt , market_cap\n"

    sorted = results.sort_by { |key, value| value[1] }
    sorted.each do |arr|
      # arr[0] key - ticker
      # arr[1] [score, stock, fair_value_combine_data]
      stock = arr[1][2]
      data = arr[1][3]
      if arr[1][0] > 0
        file.write "#{arr[0]} , #{arr[1][0]} , #{arr[1][1]} , #{stock.comment} , #{stock.rating} , #{data[:future_profit]} , #{data[:cash] - data[:debt]} , #{data[:market_cap]}\n"
      end
    end

    file.close

    return sorted
  end

end
