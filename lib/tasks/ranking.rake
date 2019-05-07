desc "Stocks seed from web"
task :ranking => :environment do

  load 'app/lib/record_processing/stock_frame.rb'

  #ActiveRecord::Base.logger = Logger.new STDOUT

  sf = 'nil'
  File.open('ranking.dump', 'r') do |f|
    sf = Marshal.load(f)
  end

  puts "rake task"
  binding.irb

end
