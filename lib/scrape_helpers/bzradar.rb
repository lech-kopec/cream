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

  end
end
