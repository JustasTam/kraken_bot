namespace :cron_bot_launcher do
	desc "Launching cron bot"
  task launch: :environment do
    kraken = KrakenController.new
    kraken.cron_logic
  end
end