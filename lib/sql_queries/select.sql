select stocks.ticker, sum(inc.net_profit), sum(bs.short_term_liabilities + bs.long_term_liabilities) as liabilities
from stocks inner join income_statements inc on stocks.id = inc.stock_id inner join balance_sheets bs on stocks.id = bs.stock_id 
where stocks.id in (3) 
  and inc.year in (2017,2016) 
  and bs.year in (2017)
group by stocks.ticker;