require 'rufus-scheduler'
require 'rake'
KrakenBot::Application.load_tasks

s = Rufus::Scheduler.new

s.every '1m' do 
  Rake::Task['launch_kraken_task'].reenable
  Rake::Task['launch_kraken_task'].invoke
end