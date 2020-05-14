class KrakenMailer < ApplicationMailer
	default from: 'kraken_bot_notifications@localhost.com'
 
  def notify_email
    @action = params[:action]
    @price = params[:price]
    @volume = params[:volume]

    mail(to: 'justas.tamulionis@gmail.com', subject: 'Kraken bot: started new action!')
  end

  def crash_report
  	@action = params[:action]
  	@raw_message = params[:raw_message]
  	@time = params[:time]

  	mail(to: 'justas.tamulionis@gmail.com', subject: 'Kraken bot: crashed!')
  end
end
