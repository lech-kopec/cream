desc "Stocks seed from web"
task :ranking_2_backtest => :environment do

  load 'app/lib/rankings/rankings.rb'

  Rankings.ranking_2_backtest; nil

end
