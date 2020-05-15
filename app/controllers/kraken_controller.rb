class KrakenController < ApplicationController
	require 'kraken_ruby_client'

	def index
		@balance = check_balance
    @my_trades = check_my_trades

    get_24hour_average

    # @active_orders = check_active_orders
    # idealy there will only be one order
    # @active_orders.first.second["descr"]["type"]
	end

	def cron_logic
		get_24hour_average # set average / cached for 5mins
		Rails.logger.fatal "Deciding what to do:"

		active_orders = check_active_orders
		balance = check_eur_balance

		if active_orders["error"].present? || balance["error"].present? # send report email if crashed
			Rails.logger.fatal "Got an error! - #{active_orders['error'] || balance['error']}"
			
			if !Rails.cache.exist?("crash_email_sent") # flag if email was already sent
				Rails.cache.fetch("crash_email_sent", :expires_in => 30.minutes) do
					KrakenMailer.with(
						action: 'Active order || balance check',
						raw_message: active_orders["error"] || balance["error"],
						time: Time.now.strftime("%F %H:%M:%S"),
					).crash_report.deliver_now
				end
			end
		else

			if active_orders["result"]["open"].any? # sitting on buy or sell
				Rails.logger.fatal "There are active order/s"

				if !Rails.cache.exist?("stuck_on_order_for_10h") # flag if email was already sent
					time_now = Time.now.strftime("%F %H:%M:%S").to_time
					order_time = Time.at(active_orders["result"]["open"].first.second["opentm"]).strftime("%F %H:%M:%S").to_time

					if (time_now > order_time + 10.hours)
						Rails.cache.fetch("stuck_on_order_for_10h", :expires_in => 30.minutes) do
							KrakenMailer.with(
								action: 'Order stuck for 10 or more hours!',
								description: active_orders["result"]["open"].first.second["descr"]["order"],
							).stuck_on_order.deliver_now
						end
					end
				end

	    elsif balance["result"]["ZEUR"].to_f.round(4) > 10 # sold / requires buy action
	    	price = calculate_price('buy')
	    	volume = balance["result"]["ZEUR"].to_f.round(4) / price
	    	volume = volume.round(4) # double check

	    	Rails.logger.fatal "Buying (price: #{price}, volume: #{volume})"
	    	KrakenMailer.with(action: 'Buying', price: price, volume: volume).notify_email.deliver_now

	    	add_buy_order(price, volume)
	    else # no active orders - meaning that buy action succeded / requires sell
	    	# TODO: notify if sell price is getting closer to bought price
	    	price = calculate_price('sell')
	    	volume = balance["result"]["USDT"].to_f.round(4)

	    	Rails.logger.fatal "Selling (price: #{price}, volume: #{volume})"
	    	KrakenMailer.with(action: 'Selling', price: price, volume: volume).notify_email.deliver_now

	    	add_sell_order(price, volume)
	    end

	  end
    Rails.logger.fatal "-------------------------------------------"
	end

	def button
		message = "Pressed the button"
		# KrakenMailer.with(user: 'abrakadabra').notify_email.deliver_now
		# KrakenMailer.with(
		# 	action: 'Checking active orders',
		# 	raw_message: "{active_orders[error]: exceeded limits}",
		# 	time: Time.now.strftime("%F %H:%M:%S"),
		# ).crash_report.deliver_now

    redirect_to home_path, flash: {message: message}
	end

	def get_24hour_average
		Rails.logger.info "Getting new 24h average"
		ticker = Rails.cache.fetch("categories", :expires_in => 5.minutes) do
		  Rails.logger.info "Caching value"
			`python lib/assets/python/sandbox_krakenapi.py Ticker pair=usdteur`
		end

		ticker = JSON.parse(ticker)

		if ticker["error"].present? 
			ticker["error"]
		else
			@average_24 = ticker["result"]["USDTEUR"]["p"].second.to_f.round(4)
			@low_24 = ticker["result"]["USDTEUR"]["l"].second.to_f.round(4)
			@high_24 = ticker["result"]["USDTEUR"]["h"].second.to_f.round(4)
			@latest_price = ticker["result"]["USDTEUR"]["c"].first.to_f.round(4)

			# @last_info = ticker["result"]["USDTEUR"]
		end
	end

	# def get_time
	# 	time_response = `python lib/assets/python/sandbox_krakenapi.py Time`
	# 	Time.at(JSON.parse(time_response)["result"]["unixtime"])
	# end

	def check_balance
		balance = JSON.parse(`python lib/assets/python/sandbox_krakenapi.py Balance`)
		if balance["error"].present?
			return balance["error"]
		else
			return balance["result"]
		end
	end

	def calculate_price(action)
		# TODO: move "0.004" num to place where it could be set dinamicaly
		margin = 0.004
		
		if action == 'buy'
			price = @average_24 - margin
			price = price > @latest_price ? (@latest_price + 0.0005) : price
		end

		if action == 'sell'
			price = @average_24 + margin
			price = price < @latest_price ? (@latest_price - 0.0005) : price
		end

		return price
	end

	def check_eur_balance
		# Rails.cache.fetch("user_usd_balance", expires_in: 10.minutes) do
		JSON.parse(`python lib/assets/python/sandbox_krakenapi.py Balance`)
		# end
	end

	def check_my_trades
		# since_today = Time.current.beginning_of_day.to_time.to_i
		# trades = JSON.parse(`python lib/assets/python/sandbox_krakenapi.py TradesHistory pair=etheur since="#{since_today}"`)
		trades = JSON.parse(`python lib/assets/python/sandbox_krakenapi.py TradesHistory pair=etheur`)

		if trades["error"].present?
			return trades["error"]
		else
			return trades["result"]["trades"]
		end
	end

	def check_active_orders
		JSON.parse(`python lib/assets/python/sandbox_krakenapi.py OpenOrders`)
	end

	def calculate_volume(balance = nil, price = nil)
		if balance && price
			return (balance / price).floor
		end
	end

	def add_buy_order(price, volume)
		`python lib/assets/python/sandbox_krakenapi.py AddOrder pair=usdteur type=buy price="#{price}" volume="#{volume}" ordertype=limit`
	end

	def add_sell_order(price, volume)
		`python lib/assets/python/sandbox_krakenapi.py AddOrder pair=usdteur type=sell price="#{price}" volume="#{volume}" ordertype=limit`
	end

	def cancel_order(id)
		# ./krakenapi.py CancelOrder txid=O7MN22-ZCX7J-TGLQHD
	end
end