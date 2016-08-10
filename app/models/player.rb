class Player < ApplicationRecord
	belongs_to :user
	belongs_to :game

	scope :on_game, -> { where(status: ["alive", "turn_on"]) }
	scope :alive, -> { where(status: "alive") }
	scope :turn_on, -> { where(status: "turn_on") }
	scope :deck, -> { where(role: "deck") }
	scope :dummy, -> { where(role: "dummy") }
end
