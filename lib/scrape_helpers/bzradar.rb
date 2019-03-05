module ScrapeHelpers
  module BzRadar
    def self.in_thousands?(doc)
      thousands = doc.xpath('//div[@class="report-disclaimer-above"]').text
      return thousands == 'dane w tys. PLN'
    end

    def self.extract_years(doc)
      years = doc.xpath('//table[@class="report-table"]/tr/th').text
      years = years.scan(/\t(\d+)\n/).flatten.map(&:to_i)
      return years
    end

    def self.extract_quarters(doc)
      text = doc.xpath('/html/body/div[2]/div[2]/div[1]/div/main/div/div/div[4]/table/tr[1]').text
      quarters = text.scan(/\t(\d+\/..)\n/).flatten
      return quarters
    end

    def self.find_quarterly_link(url, domain_name)
      puts "Fetching #{url}"
      begin
        doc = Nokogiri::HTML(open(url))
      rescue
        $logger.warn("404 url" + url )
        return nil
      end

      empty = doc.xpath('/html/body/div[2]/div[2]/div[1]/div/main/div/div/p')
      unless empty.blank?
        puts "Blank"
        return nil
      end
      puts "Error opening url" + url unless doc

      new_link = doc.xpath('/html/body/div[2]/div[2]/div[1]/div/main/div/div/div[4]/div[1]/a[1]')
      return nil unless new_link.length > 0
      new_link = new_link.attr('href').value
      unless new_link
        puts "missing quarter link"
        return nil
      end
      new_link = domain_name + new_link
    end

  end
end
