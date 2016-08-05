class CreatePockercards < ActiveRecord::Migration[5.0]
  def change
    create_table :pockercards do |t|
      t.string :shape
      t.string :number
      t.string :effect
      t.integer :player_id
      t.integer :order

      t.timestamps
    end
  end
end
