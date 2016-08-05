class CreateGames < ActiveRecord::Migration[5.0]
  def change
    create_table :games do |t|
      t.string :play_order
      t.string :winner_id
      t.string :status

      t.timestamps
    end
  end
end
