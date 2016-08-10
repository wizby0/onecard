class Pockercard < ApplicationRecord


	scope :on_deck_ids, -> { where(player_id: '1').ids }#cards on deck
end
