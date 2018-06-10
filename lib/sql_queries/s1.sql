--select stocks.ticker, bs.year as bsyear, bs.short_term_liabilities, bs.long_term_liabilities, inc.net_profit, inc.year as incyear
--from stocks
--  inner join balance_sheets bs on stocks.id = bs.stock_id 
--  inner join income_statements inc on stocks.id = inc.stock_id
--where stocks.id in (3) 
--  and inc.year in (2016,2015,2017) 
--  and bs.year in (2017, 2015, 2014)
--order by bs.year asc, inc.year asc
--;

(
select stocks.id as id, stocks.ticker, 0 as bsyear, 0 as stl, null as ltl, inc.net_profit, inc.year as incyear
from stocks
  inner join income_statements inc on stocks.id = inc.stock_id
where 
  stocks.id in (3,4) 
  and 
  inc.year in (2016,2015,2017) 
)
union
(
select stocks.id as id, stocks.ticker, bs.year as bsyear, bs.short_term_liabilities as stl, bs.long_term_liabilities as ltl, 0, 0
from stocks
  inner join balance_sheets bs on stocks.id = bs.stock_id 
where 
  stocks.id in (3,4) 
  and 
  bs.year in (2017, 2014)
)
order by id asc, incyear asc, bsyear asc
