module PriceImporters
  module MstallDB
    def self.import_historical(stock)
      if stock.prices.any?
        @@latest_price_date = stock.prices.latest.time.to_date
      else
        @@latest_price_date = Date.parse('19900101')
      end

      puts "Opening file for " + stock.name
      File.open("tmp/mstall/#{stock.name.upcase}.mst").readlines.each do |line|

        next if line.include? 'TICKER'
        attrs = self.line_to_stock_attrs line
        next if @@latest_price_date >= attrs[:time]
        attrs[:stock_id] = stock.id
        Price.create!(attrs)
        #x = stock.prices.create! attrs; nil

        attrs = nil
        line = nil
      end
      puts "Finished processing file for " + stock.name
    end

    def self.line_to_stock_attrs(line)
      elems = line.split(',')
      date = DateTime.parse elems[1]
      open = elems[2].to_d
      high = elems[3].to_d
      low = elems[4].to_d
      close = elems[5].to_d
      volume = elems[6].scan(/\d+/)[0].to_d
      return {
        time: date,
        open: open,
        high: high,
        low: low,
        close: close,
        volume: volume
      }
      
    end
  end
end
