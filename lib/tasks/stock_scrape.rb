module Scrape
  require 'open-uri'
  require 'irb'
  require_relative '../translators/income_statement'
  require_relative '../scrape_helpers/bzradar'

  module BiznesRadar
    scrape_configs = YAML.load_file('config/scrapper.yml')
    $domain_name = scrape_configs["bz_domain_name"]
    $basic_url = scrape_configs["bz_basic_url"]

    def self.seed_from_index(url, index)
      market = Market.find_by_name(index)
      puts "Fetching stocks from " + url

      doc = Nokogiri::HTML(open(url))
      puts "Error opening url" + url unless doc

      doc.xpath('//table[@class="qTableFull"]/tr').each do |tr_node|
        next unless tr_node.children[1].name == 'td'
        stock = tr_node.children[1].text.split(" ")

        next unless stock[0] && stock[1]

        name = stock[1].gsub(/[\(\)]/, '')
        ticker = stock[0]

        if ticker.length > 5
          $logger.warn("Skipping suspicius ticker" + ticker)
          next
        end
        
        puts "creating new stock: " + name + " " + ticker
        Stock.find_or_create_by(name: name, market: market) do |stock|
          stock.ticker = ticker
          stock.save!
        end
      end
    end

    def self.seed_details(stock)
      url = $basic_url + stock.ticker

      #self.assign_basic_details_to stock

      self.assign_income_statements_to stock

      #self.assign_balance_sheets_to stock
    end

    def self.assign_basic_details_to(stock)
        url = $basic_url + stock.ticker
        puts "Fetching stock details from " + url
        stock_details = self.extractStockDetails(url)
        return unless stock_details
        puts "Updating stock with info:" + stock.name
        stock.isin = stock_details[:isin]
        stock.debut = stock_details[:debut]
        stock.shares = stock_details[:shares]
        stock.website = stock_details[:website]
        sector = Sector.find_by_org_name(stock_details[:sector])
        if sector
          stock.sector_id = sector.id
        else
          $logger.warn('No sector found for:' + stock.ticker)
        end
        stock.save!
    end

    def self.add_quarterly_income_statements(stock)
      url = $domain_name + 'raporty-finansowe-rachunek-zyskow-i-strat/' + stock.ticker
      income_statements = self.extractIncomeStatementsQuarterly(url)
      return unless income_statements
      income_statements.each do |key, values|
        period = key.split('/')
        year = period[0].to_i
        quarter = period[1].scan(/\d+/)[0].to_i
        if year == 2018
          stock.income_statements.find_or_create_by(year: year, quarter: quarter) do |is|
            puts "Current id: #{is.id}"
            is.update_attributes(values)
          end
        end
      end
    end

    def self.add_quarterly_balance_sheets(stock)
      url = $domain_name + 'raporty-finansowe-bilans/' + stock.ticker
      quarterly_url = ScrapeHelpers::BzRadar.find_quarterly_link(url, $domain_name)
      unless quarterly_url
        $logger.warn("no quarterly_url " + stock.ticker )
        return
      end
      puts "quarterly_url: #{quarterly_url }"
      income_statements = self.extract_balance_sheets_quarterly(quarterly_url)
      return unless income_statements
      income_statements.each do |key, values|
        period = key.split('/')
        year = period[0].to_i
        quarter = period[1].scan(/\d+/)[0].to_i
        stock.balance_sheets.find_or_create_by(year: year, quarter: quarter) do |is|
          is.update_attributes(values)
        end
      end
    end

    def self.assign_income_statements_to(stock)
      url = $domain_name + 'raporty-finansowe-rachunek-zyskow-i-strat/' + stock.ticker
      return unless stock.income_statements.blank?
      income_statements = self.extractIncomeStatementsYearly(url)
      return unless income_statements
      income_statements.each do |key, values|
        stock.income_statements.find_or_create_by(year: key, quarter: nil) do |is|
          is.update_attributes values
        end
      end
    end

    def self.assign_balance_sheets_to(stock)
      url = $domain_name + 'raporty-finansowe-bilans/' + stock.ticker
      return unless stock.balance_sheets.blank?
      balance_sheets = self.extract_balance_sheets_yearly(url)
      return unless balance_sheets
      balance_sheets.each do |key, values|
        stock.balance_sheets.find_or_create_by(year: key, quarter: nil) do |bs|
          bs.update_attributes(values)
        end
      end
    end

    def self.extractStockDetails(url)
      doc = Nokogiri::HTML(open(url))

      sidebar_infos = doc.xpath('//div[@class="box-left"]/table/tr')

      isin = nil
      debut = nil
      shares = nil
      sector = nil
      sidebar_infos.each do |row|
        row = row.text.gsub(/\n\t+/,'')
        elems = row.split(':')
        if elems[0].include? 'ISIN'
          isin = elems[1].gsub(/\s/,'')
          next
        end
        if elems[0].include? 'Liczba'
          shares = elems[1].gsub(/\s/,'').to_i
          next
        end
        if elems[0].include? 'Data'
          debut = Date.parse(elems[1])
          next
        end
        if elems[0].include? 'Sektor'
          sector = elems[2].strip
          break
        end
      end

      if !isin && !shares
        $logger.warn('Breaking, Missing data for url' + url)
        return nil
      end
      $logger.warn('Missing sector for url' + url) unless sector

      binding.irb unless isin && shares

      website = doc.xpath('//table/tr/th[text()="WWW:"]/following-sibling::td').text

      return {
        isin: isin,
        debut: debut,
        shares: shares,
        website: website,
        sector: sector
      }
    end

    def self.extractIncomeStatementsYearly(url)
      return self.extractIncomeStatements(url)
    end

    def self.extractIncomeStatementsQuarterly(url)
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
      new_link = $domain_name + new_link
      return self.extractIncomeStatements(new_link,true)
    end

    def self.extract_balance_sheets_yearly(url)
      return self.extract_balance_sheet(url)
    end
    def self.extract_balance_sheets_quarterly(url)
      return self.extract_balance_sheet(url, true)
    end

    def self.extract_balance_sheet(url, is_quarterly = false)
      puts "Fetching balance sheet from " + url
      begin
        doc = Nokogiri::HTML(open(url))
      rescue OpenURI::HTTPError => e
        $logger.warn("404 url" + url )
        return nil
      end

      thousands = ScrapeHelpers::BzRadar.in_thousands?(doc)

      matrix = {}
      years = ScrapeHelpers::BzRadar.extract_years doc
      quarters = ScrapeHelpers::BzRadar.extract_quarters doc
      if is_quarterly
        return nil if quarters.blank?
      else
        return nil if years.blank?
      end
      first_year = years[0]

      ( is_quarterly ? quarters : years ).each do |period|
        matrix[period] = {}
      end

      rows = doc.xpath('//table[@class="report-table"]/tr')
      rows.each_with_index do |row, row_index|
        category = row.children[0].text
        category = Translators::BzRadar.tr category if row_index < 25
        category = Translators::BzRadar.tr2 category if row_index > 24
        next if category == nil
        next if category == 'ignore'
        row.children[1..-2].each_with_index do |col, col_index|
          begin
            matrix_index = is_quarterly ? quarters[col_index] : col_index + first_year
            next unless years.include? matrix_index
            value = col.xpath('.//span[@class="value"]').text
            value = value.gsub(' ','')
            value = 0 if value.blank?
            value = value.to_d
            value = value / 1000 unless thousands
            matrix[matrix_index][category] = value
          rescue
            puts "matrix[matrix_index][category] = value"
            binding.irb
          end
        end
      end
      return matrix
    end

    def self.extractIncomeStatements(url, is_quarterly = false)
      puts "Fetching income_statements from " + url
      doc = Nokogiri::HTML(open(url))

      empty = doc.xpath('/html/body/div[2]/div[2]/div[1]/div/main/div/div/p')
      return nil unless empty.blank?
      puts "Error opening url" + url unless doc

      thousands = doc.xpath('//div[@class="report-disclaimer-above"]').text
      thousands = thousands == 'dane w tys. PLN'

      matrix = {}
      rows = doc.xpath('//table[@class="report-table"]/tr')

      begin
        periods = rows[0].text.scan(/\t(\d+)\n/).flatten.map(&:to_i)
        quarters = rows[0].text.scan(/\t(\d+\/..)\n/).flatten
      rescue NoMethodError => e
        binding.irb
      end
      first_year = periods[0]

      ( is_quarterly ? quarters : periods ).each do |period|
        matrix[period] = {}
      end

      rows.each_with_index do |row, index|
        next if index == 0
        category = nil
        row.children.each_with_index do |col, col_index|
          col_text = col.text.gsub(/r\/r.*$/,'')
          next if col_text.blank?
          if col_index == 0
            tr = Translators::BzRadar.tr col_text
            break unless tr
            break if tr == 'ignore'
            category = tr
            next
          end
          value = col.xpath('.//span[@class="value"]').text.gsub(' ','')
          value = 0 if !value || value.length == 0
          begin
            value = value.to_d
            value = value / 1000 unless thousands
            matrix_index = is_quarterly ? quarters[col_index - 1] : col_index-1+first_year
            matrix[matrix_index][category] = value
          rescue NoMethodError => e
            # this happens when we go over available years with some extra columns
          rescue ArgumentError => e
            binding.irb
            $logger.warn("ArgumentError for url" + url + " col: " + col)
          end
        end
      end

      return matrix
    end
  end
end
