class Game < ApplicationRecord
	has_many :players
	has_many :users, through: :players

    def toggle_order!
    	if play_order == "clock_wise"
    		self.update!(play_order: "counter_clock_wise")
    	else
    		self.update!(play_order: "clock_wise")
    	end
    end
end
