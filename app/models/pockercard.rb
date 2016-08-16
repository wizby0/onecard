class Pockercard < ApplicationRecord


	scope :on_deck_ids, -> { where(player_id: '1').ids }#cards on deck
	scope :on_dummy_ids, -> { where(player_id: '2').ids }#cards on dummy
end
