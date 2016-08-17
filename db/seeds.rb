# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

pockercard_list = [["spade", "A","attack"],["spade", "2","attack"],["spade", "3","none"],["spade", "4","none"],
["spade", "5","none"],["spade", "6","none"],["spade", "7","change"],["spade", "8","none"],
["spade", "9","none"],["spade", "10","none"],["spade", "J","jump"],["spade", "Q","back"],
["spade", "K","onemore"],["clover", "A","attack"],["clover", "2","attack"],["clover", "3","none"],
["clover", "4","none"],["clover", "5","none"],["clover", "6","none"],["clover", "7","change"],
["clover", "8","none"],["clover", "9","none"],["clover", "10","none"],["clover", "J","jump"],
["clover", "Q","back"],["clover", "K","onemore"],["diamond", "A","attack"],["diamond", "2","attack"],
["diamond", "3","none"],["diamond", "4","none"],["diamond", "5","none"],["diamond", "6","none"],
["diamond", "7","change"],["diamond", "8","none"],["diamond", "9","none"],["diamond", "10","none"],
["diamond", "J","jump"],["diamond", "Q","back"],["diamond", "K","onemore"],["heart", "A","attack"],
["heart", "2","attack"],["heart", "3","none"],["heart", "4","none"],["heart", "5","none"],["heart", "6","none"],
["heart", "7","change"],["heart", "8","none"],["heart", "9","none"],["heart", "10","none"],["heart", "J","jump"],
["heart", "Q","back"],["heart", "K","onemore"],["black", "JOCKER","attack"],["color", "JOCKER","attack"]]

pockercard_list.each_with_index do |pockercard_list,index|
  pockercard = Pockercard.new
  pockercard.shape = "#{pockercard_list[0]}"
  pockercard.number = "#{pockercard_list[1]}"
  pockercard.effect = "#{pockercard_list[2]}"

  if index%10 == 0
    pockercard.player_id = "3"
  elsif index % 10 == 2
    pockercard.player_id = "4"
  elsif index % 10 == 4  
    pockercard.player_id = "5"
  elsif index %10 == 6
    pockercard.player_id = "6"
  elsif index %10 == 8
    pockercard.player_id = "7"
  else
    pockercard.player_id = "1"
  end
  
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



players_list = [["deck", "deck"],["dummy", "dummy"],["first", "first"], ["second", "second"],["third", "third"],["fourth", "fourth"],["fifth", "fifth"]]
players_list.each_with_index do |player,index|
  player = Player.new
  player.game_id = "1"
  
  if index == 1
  	player.role == "admin"
  end
  if index >1
    player.user_id = index - 1
    player.status = "alive"
  else
    player.role = players_list[index][1]
    player.user_id = 1  #admin user id added
  end
  player.save!
end

