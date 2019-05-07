module ScrapeHelpers

  module BzRadar

    module CashFlow

      def self.row_extract(doc,i, bzLabel, row_index)
        label = doc.xpath("//table[@class='report-table']/tr[#{row_index}]/td[1]").text
        raise "Missing row: #{row_index} CF: #{label} for #{doc.title}" unless label == bzLabel
        index = i + 2
        return doc.xpath("//table[@class='report-table']/tr[#{row_index}]/td[#{index}]/span[@class='value']")
      end

      def self.operating_cash_flow(doc, i)
        index = i + 2
        label = doc.xpath('//table[@class="report-table"]/tr[2]/td[1]/strong/a').text
        unless label == 'Przepływy pieniężne z działalności operacyjnej'
          raise "Missing Przepływy pieniężne z działalności operacyjnej: #{label} for #{doc.title}"
        end
        ocf = doc.xpath("//table[@class='report-table']/tr[2]/td[#{index}]/span[@class='value']/span/span")
        return ScrapeHelpers.node_to_decimal(ocf)
      end

      def self.amortization(doc, i)
        node = ScrapeHelpers::BzRadar::CashFlow.row_extract(doc, i,
          'Amortyzacja',
          3
        )
        return ScrapeHelpers.node_to_decimal(node)
      end

      def self.investing_cash_flow(doc, i)
        node = ScrapeHelpers::BzRadar::CashFlow.row_extract(doc, i,
          'Przepływy pieniężne z działalności inwestycyjnej',
          4
        )
        return ScrapeHelpers.node_to_decimal(node)
      end

      def self.capex(doc,i)
        node = ScrapeHelpers::BzRadar::CashFlow.row_extract(doc, i,
          'CAPEX (niematerialne i rzeczowe)',
          5
        )
        return ScrapeHelpers.node_to_decimal(node)
      end

      def self.financial_cash_flow(doc,i)
        node = ScrapeHelpers::BzRadar::CashFlow.row_extract(doc, i,
          'Przepływy pieniężne z działalności finansowej',
          6
        )
        return ScrapeHelpers.node_to_decimal(node)
      end

      def self.shares_issue(doc,i)
        node = ScrapeHelpers::BzRadar::CashFlow.row_extract(doc, i,
          'Emisja akcji',
          7
        )
        return ScrapeHelpers.node_to_decimal(node)
      end

      def self.dividend(doc,i)
        node = ScrapeHelpers::BzRadar::CashFlow.row_extract(doc, i,
          'Dywidenda',
          8
        )
        return ScrapeHelpers.node_to_decimal(node)
      end

      def self.total_cash_flow(doc,i)
        node = ScrapeHelpers::BzRadar::CashFlow.row_extract(doc, i,
          'Przepływy pieniężne razem',
          9
        )
        return ScrapeHelpers.node_to_decimal(node)
      end
    end
  end
end
