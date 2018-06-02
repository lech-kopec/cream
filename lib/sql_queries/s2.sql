( select stocks.id as id, stocks.ticker as ticker, null as bsyear, null as stl, null as ltl, null as net_profit, null as incyear
from stocks 
where stocks.id in (3, 4) 
)
union
(
select stock_id as id, null as ticker, 0 as bsyear, 0 as stl, 0 as ltl, inc.net_profit as net_profit, inc.year as incyear
from income_statements inc 
where 
inc.stock_id in (3,4)
  and inc.year in (2016,2015,2017) 
)
union
(
select stock_id as id, null as ticker, bs.year as bsyear, bs.short_term_liabilities as stl, bs.long_term_liabilities as ltl, null as net_profit, null as incyear
from balance_sheets bs 
where 
bs.stock_id in (3,4)
  and bs.year in (2017, 2014)
)
order by id asc, incyear asc, bsyear asc
;
