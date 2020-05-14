class ProjectedGrowthController < ActionController::Base

def test(bank, days)
	starting_bank = bank
	p "----------------------"
	p "bank at #{bank}"
	buy = 0.92
	p "buy price - #{buy}"
	sell = 0.93
	p "sell price - #{sell}"
	p "possible trades a day range from 0 - 3 (average)"
	p "----------------------"
	p " "

	days.times do |day|
		rand(0..3).times do |trade| # average from 0 to 3 trades a day
			p "----------------------"
	  	coin_bought = bank / buy
	  	bank_before_tax = coin_bought * sell
	  	fee = (bank_before_tax / 100) * 0.26

			p "Day: #{day+1}, coins: #{coin_bought}, trade number: #{trade+1}"

	  	bank = bank_before_tax - fee * 2
	  end

	  p "Bank at: #{bank}"
	  p "----------------------"
	  p " "
	end

	p " "
	p "During #{days} days made: #{(bank-starting_bank).round(3)} eur"
end

# yeah i wish
#from 267 to 471 (30days)
#from 471 to 745
#from 745 to 1088
#from 1088 to 1590 (500 month)
#from 1590 to 2646 (1050 month)
#from 2646 to 4189 (1543 month)
#from 4189 to 6632 (2443 month)
#from 6632 to 10712 (4k month)
#bank at 15502 (4790 month) (removed 30% for taxes ~3.5k month)

#realistic >
#from 250 to 320 (70)
#from 320 to 380 (60)
#from 380 to 505 (125)
#from 505 to 617 (112)
#from 617 to 830 (213)
#from 830 to 1122 (293)
#from 1122 to 1467 (345)
#from 1467 to 2018 (551)
#from 2018 to 2610 (592)

end