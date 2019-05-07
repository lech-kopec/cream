module ScrapeHelpers
  def self.node_to_decimal(node)
    value = node.text.gsub(' ','')
    value = value.length > 0 ? value : 0.0
    return value.to_d
  end

  module BzRadar

    scrape_configs = YAML.load_file('config/scrapper.yml')
    $domain_name = scrape_configs["bz_domain_name"]

    def self.in_thousands?(doc)
      thousands = doc.xpath('//div[@class="report-disclaimer-above"]').text
      return thousands == 'dane w tys. PLN'
    end

    def self.extract_years(doc)
      years = doc.xpath('//table[@class="report-table"]/tr/th').text
      return years.scan(/\t(\d+)/).flatten.map(&:to_i)
    end

    def self.extract_quarters(doc)
      text = doc.xpath('/html/body/div[2]/div[2]/div[1]/div/main/div/div/div[4]/table/tr[1]').text
      quarters = text.scan(/\t(\d+...)/).flatten
      return quarters
    end

    def self.find_quarterly_link_in_doc(doc)
      a_element = doc.xpath('//div[@id="profile-finreports"]/div/a[1]')
      if !a_element || a_element.blank?
        $logger.warn("#{Time.now} No quarterly_url for #{doc.title}")
        return nil
      end
      new_link = a_element.attr('href').value
      return nil unless new_link
      return $domain_name + new_link
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
