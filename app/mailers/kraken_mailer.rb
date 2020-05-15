class KrakenMailer < ApplicationMailer
	default from: 'kraken_bot_notifications@localhost.com'
 
  def notify_email
    @action = params[:action]
    @price = params[:price]
    @volume = params[:volume]

    mail(to: Rails.application.secrets.email_for_notifications, subject: 'Kraken bot: started new action!')
  end

  def crash_report
  	@action = params[:action]
  	@raw_message = params[:raw_message]
  	@time = params[:time]

  	mail(to: Rails.application.secrets.email_for_notifications, subject: 'Kraken bot: crashed!')
  end

  def stuck_on_order
    @action = params[:action]
    @description = params[:description]

    mail(to: Rails.application.secrets.email_for_notifications, subject: 'Kraken bot: order stuck!')
  end
end
