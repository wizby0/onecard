# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

pockercard_list = [["spade", "1"], ["diamond", "j"], ["heart", "q"], ["clover", "k"],["spade", "2"], ["diamond", "3"], ["heart", "4"], ["clover", "5"],["spade", "6"], ["diamond", "7"], ["heart", "8"], ["clover", "9"]]

pockercard_list.each_with_index do |pockercard_list,index|
  pockercard = Pockercard.new
  pockercard.shape = "#{pockercard_list[0]}"
  pockercard.number = "#{pockercard_list[1]}"
  
  pockercard.save!
end

members_list = [["first", "first"], ["second", "second"],["third", "third"],["fourth", "fourth"],["fifth", "fifth"]]
members_list.each_with_index do |member,index|
  user = User.new
  user.name = "#{member[1]}"
  user.email = "#{member[0]}@test.com"
  user.password = "0147852"
  user.password_confirmation = "0147852"

  user.save!
end


game = Game.new
game.play_order = "clock_wise"
game.status = "ready"
game.save!



players_list = [["first", "first"], ["second", "second"],["third", "third"],["fourth", "fourth"],["fifth", "fifth"]]
players_list.each_with_index do |player,index|
  player = Player.new
  player.game_id = "1"
  player.status = "alive"
  if index == 1
  	player.role == "admin"
  end
  player.user_id = index + 1

  player.save!
end


