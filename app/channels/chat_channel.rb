# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class ChatChannel < ApplicationCable::Channel
  @@deck_list = []

 def subscribed
  stream_from 'messages'
  end

  def speak(data)
    ActionCable.server.broadcast('messages',
    message: render_message(data['message']))
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def user_join
    display_userListInfomessage()
    display_cardListInfomessage()
  end
  

  def test_function  
    # display_turnOnPlayer()
    # display_cardListInfomessage()
    command_endTurn()
    # command_shuffle()
    # display_cardListInfomessage()
  end

  def test_function2  
    # action_endTurn()
    # action_moveCard()
    # display_cardListInfomessage()
    command_jump()
    display_userListInfomessage()
  end



  def command_totals()


    #default value setting
    # sourcePlayer_id = Player.find_by(game_id: Game.last.id, user_id: User.find_by(name: current_user).id).id
    targetCard_id = 20
    action_message = "draw_card" #action command


    if action_message == "draw_card"
      targetCard_id = Pockercard.on_deck_ids.sample(1)[0]

      sourcePlayer_id = Game.last.players.deck.id
      destPlayer_id = Game.last.players.find_by(user: current_user,role: nil).id
      pockerCard_id = targetCard_id

    elsif action_message == "use_card"
      if Game.last.players.find_by(user: current_user,role: nil).id == Pockercard.find_by(id:targetCard_id).player_id #only owner can play card      
        sourcePlayer_id = Game.last.players.find_by(user: current_user,role: nil).id
        destPlayer_id = Game.last.players.dummy.id
        pockerCard_id = targetCard_id
      end
    end
    command_moveCard(dest_id: destPlayer_id, source_id: sourcePlayer_id, card_id: pockerCard_id)

  end

  def command_shuffle()

    old_cards = Pockercard.order(:id).pluck(:id)
    shuffled_cards = old_cards.sample(old_cards.count)

    alive_player = Game.last.players.on_game.order(:id)
    alive_player_ids = alive_player.ids


    #alive_player_num 2->cards 7, 3->cards 5, 4->cards 5
    if alive_player.size == 2
      cards_num = 7
    elsif alive_player.size == 3
      cards_num = 6
    else
      cards_num = 5
    end

    count_index = 1
    shuffled_cards.each_with_index do |card_index, index|

      if index < alive_player_ids.size*cards_num
        if index  >= count_index*cards_num
          count_index += 1
        end
        Pockercard.find(card_index).update(player_id: alive_player_ids[count_index-1])
      else
        Pockercard.find(card_index).update(player_id: '1')#deck
      end

    end
  end

  def command_moveCard(data)
    action_moveCard(data)
    display_cardListInfomessage()
  end

   def command_endTurn()
      turn_step = 1
      action_endTurn(turn_step)
      display_userListInfomessage()
    end

    def command_jump()
      turn_step = 2
      action_endTurn(turn_step)
      display_userListInfomessage()
    end

  private

  # def render_message(message)
  #   ApplicationController.render(partial: 'messages/message',
  #                                locals: { message: message })
  # end
  def render_message(message)
   ApplicationController.render(
     partial: 'messages/message',
     locals: {
       message: message,
       username: current_user.name
       })
  end

  def display_userListInfomessage()

    # players = Player.where(game_id:Game.last.id)
    players = Game.last.players
    count_number = Player.where(game_id: Game.last.id, role: nil).count #count player except deck and dummy
    ActionCable.server.broadcast('messages', players: players.each_with_index.map{|player, index| { index: index+1, name: player.user.name, status: player.status }}, count_number: count_number, system_info: "players_lists")
    
  end


  def display_cardListInfomessage()
    ActionCable.server.broadcast('messages', system_info: "clear_list")
    players = Player.where(game_id:Game.last.id)
    players.each_with_index do |player, index|
      if index >=2         
        player_name = User.find(player.id-2).name
      else
        player_name = player.role
      end
      count_card = Pockercard.where(player_id: player.id).count
      pockers = Pockercard.where(player_id: player.id)

      ActionCable.server.broadcast('messages', list_info: {player_id: player.id, player_name: player_name, pockers_number: count_card} , system_info: "lists_start")
      ActionCable.server.broadcast('messages', pockers_number: count_card, pockers: pockers.each_with_index.map{|pocker, index| { index: pocker.id, shape: pocker.shape, number: pocker.number }}, system_info: "pockers_lists")
      ActionCable.server.broadcast('messages', system_info: "lists_end")    
    end
  
  end

  def display_turnOnPlayer()
    turnPlayer = Player.where(status:"turn_on").last
    ActionCable.server.broadcast('messages', player_id: turnPlayer.id-2 ,system_info: "turn_on") 
  end

  def action_moveCard(data)
    
    tempCard_id = data[:card_id]
    tempPlayer_id = data[:dest_id]
    sourcePlayer_id = data[:source_id]

    destPlayer_id = tempPlayer_id
    Pockercard.find(tempCard_id).update(player_id: destPlayer_id)

    ActionCable.server.broadcast('messages', system_info: "move_card")  
    
  end

  #jayoon's coding
  def action_endTurn(turn_step)
    # turn_step = 1 #default step
    game = Game.last

    turn_player = game.players.turn_on.last
    alive_player_ids = game.players.on_game.order(:id).ids #alive player's id
    # Player.order(:id).map{|p| p.status}
    # Player.order(:id).pluck(:id)
    # Player.order(:id).pluck(:id, :status)
    # Player.order(:id).pluck('id * 2')

    index = alive_player_ids.find_index(turn_player.id)
    next_turn_index = ( index + ( turn_step * ( game.play_order == "clock_wise" ? 1 : -1 ) ) ) % alive_player_ids.size
    next_turn_player = Player.find(alive_player_ids[next_turn_index])

    turn_player.update!(status: "alive")
    next_turn_player.update(status: "turn_on")
  end

  #my coding
  # def action_endTurn()

  #   turn_step = 1 #default step
  #   game_id = Game.last.id

  #   turnPlayer = Player.where(game_id: game_id, status:"turn_on").last
  #   alivePlayers = Player.where(game_id: game_id, status:["alive","turn_on"]).order(:id) #alive player's id

  #   turnPlayer_index =0  #init
  #   nextTurn_index =0  #init



  #   alivePlayers.each_with_index do |alivePlayer, index|  #find out index in alive player array (not id)
  #     if alivePlayer.user_id == turnPlayer.user_id
  #       turnPlayer_index = index
  #     end
  #   end

  #   game.players.on_game


  #   max_index = alivePlayers.count

  #   if Game.last.play_order == "clock_wise"   #move index for 1 step
  #     nextTurn_index = turnPlayer_index + turn_step
  #   else
  #     nextTurn_index = turnPlayer_index - turn_step
  #   end

  #   if nextTurn_index < 0           #check underflow
  #     nextTurn_index += max_index
  #   end

  #   if nextTurn_index >= max_index  #check overflow
  #     nextTurn_index -= max_index
  #   end

  #   Player.find(alivePlayers[turnPlayer_index].id).update(status: "alive") #change active player to deactive
  #   Player.find(alivePlayers[nextTurn_index].id).update(status: "turn_on") #change active player to deactive
    
  # end


end
