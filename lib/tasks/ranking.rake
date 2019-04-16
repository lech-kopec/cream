desc "Stocks seed from web"
task :ranking => :environment do

  load 'app/lib/rankings/rankings.rb'

  Rankings.ranking_2; nil

end
