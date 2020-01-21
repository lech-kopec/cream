module StockFrames

  class Frame

    def initialize(hash)
      @data = {}
      hash.each_pair do |key, value|
        if value.is_a? Array
          @data[key] = value
        else
          @data[key] = value
        end
      end
    end

    def method_missing(m, *args, &block)

      key = m.to_s

      if @data[key]
        if @data[key].is_a? Array
          return @data[key]
        else
          return @data[key] || @data[key.to_sym]
        end
      end
    end

    def id
      return @data["stock_id"][0]
    end

    def attach_prices!(prices)
      @data["close"] = prices.map(&:close)
    end

    def add_property(key, value)
      @data[key] = value
    end

    def growth_on(prop)
      result = (@data[prop].last / @data[prop].first)
      result = result.to_r.to_d(10) + 0.0001 rescue 0.0001
      return result
    end

    def working_capital(index)
      assets[index] - short_term_liabilities[index]
    end

    def shares
      return @data["shares"] / 1000
    end

    def price_on_report(i)
      return @data["prices"][i][1]
    end

  end
end
