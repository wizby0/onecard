class Game < ApplicationRecord
	has_many :Player
	has_many :users, through: :mapia
end
