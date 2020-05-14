# # config/initializers/rufus_scheduler.rb
# require 'rufus-scheduler'
# require 'rake'
# MyRailsApp::Application.load_tasks

# # Let's use the rufus-scheduler singleton
# #
# s = Rufus::Scheduler.singleton

# # Awesome recurrent task...
# #
# s.every '1m' do
#   rake 'cron_bot_launcher:launch'
# end

require 'rufus-scheduler'
require 'rake'
KrakenBot::Application.load_tasks

# load File.join(Rails.root, 'lib', 'tasks', 'task_runner.rake')
s = Rufus::Scheduler.new

# s.every '1m' do 
#   Rake::Task['launch_kraken_task'].reenable
#   Rake::Task['launch_kraken_task'].invoke
# end