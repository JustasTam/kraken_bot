task :launch_kraken_task => :environment do 
  puts '-----------------------------------------------------------'
  puts 'Running kraken cron logic'
  KrakenController.new.cron_logic
end