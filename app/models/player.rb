class Player < ApplicationRecord
	belongs_to :user
	belongs_to :game

	scope :on_game, -> { where(status: ["alive", "turn_on"]) }
	scope :alive, -> { where(status: "alive") }
	scope :turn_on, -> { where(status: "turn_on") }

	#one player
	scope :deck, -> { where(role: "deck").last }
	scope :dummy, -> { where(role: "dummy").last }
	scope :by_user, -> (user) { find_by(user: user, role: nil) }
end
