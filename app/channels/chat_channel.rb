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
  

  def command_start 
    command_shuffle()
    display_cardListInfomessage()
  end

  def command_drawCard 
    action_drawCard()
    display_cardListInfomessage()
  end



  def test_function  
    # display_turnOnPlayer()
    # display_cardListInfomessage()
    command_endTurn()
    # command_shuffle()
    display_cardListInfomessage()
  end

  def test_function2  
    # action_endTurn()
    # action_moveCard()
    # display_cardListInfomessage()
    # command_jump()
    command_totals()
    
  end



  def command_totals()

    #default value setting
    # sourcePlayer_id = Player.find_by(game_id: Game.last.id, user_id: User.find_by(name: current_user).id).id
    targetCard_id = 39
    action_message = "use_card" #action command


    if action_message == "draw_card"
      action_drawCard()
    elsif action_message == "use_card"
      action_useCard(targetCard_id)
    end
    
  end

  def command_shuffle()
    Pockercard.all.update_all(player_id: 1)

    alive_players = Game.last.players.on_game.order(:id)
    #alive_player_num 2->cards 7, 3->cards 5, 4->cards 5
    if alive_players.size == 2
      cards_num = 7
    elsif alive_players.size == 3
      cards_num = 6
    else
      cards_num = 5
    end

    shuffled_card_ids = Pockercard.order('RANDOM()').ids
    alive_players.each do |player|
      target_cards = Pockercard.where(id: shuffled_card_ids.slice!(0,cards_num))
      target_cards.update_all(player_id: player.id)
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
    players = Game.last.players.order(:id)
    count_number = Player.where(game_id: Game.last.id, role: nil).count #count player except deck and dummy
    # count_number = Player.where(game_id: Game.last.id).count #count player whith deck and dummy
    ActionCable.server.broadcast('messages', players: players.each_with_index.map{|player, index| { index: index+1, name: player.user.name, status: player.status }}, count_number: count_number, system_info: "players_lists")
    
  end


  def display_cardListInfomessage()
    ActionCable.server.broadcast('messages', system_info: "clear_list")
    players = Player.where(game_id:Game.last.id).order(:id)
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

#============ check condition functions ================
  
  def check_cardOwn(card_id) #authroity
    
    value_return = false

    if Game.last.players.find_by(user: current_user,role: nil).id == Pockercard.find_by(id:card_id).player_id
      value_return = true
    end

    return value_return
    
  end



#=============== partial action functions =================


  def action_useCard(pockerCard_id)
    if check_cardOwn(pockerCard_id)#only owner can play card  
      sourcePlayer_id = Game.last.players.by_user(current_user).id
      destPlayer_id = Game.last.players.dummy.id # destPlayer_id = 2 (dummy)          
    
      command_moveCard(dest_id: destPlayer_id, source_id: sourcePlayer_id, card_id: pockerCard_id)
  
      #check effect of cards
      card_effect = Pockercard.find(pockerCard_id).effect
      if card_effect == "none"
        action_endTurn(1) #move to next player=[
      elsif card_effect == "back"     
        Game.last.toggle_order!
        action_endTurn(1) #skip next player
      elsif card_effect == "jump"  
        action_endTurn(2) #move to next next player
      elsif card_effect == "attack"  
        action_endTurn(2) #move to next next player
      elsif card_effect == "onemore" 
      else
        action_endTurn(1) #skip next player
      end
    end

    display_userListInfomessage()

  end

  def action_drawCard()
    targetCard_id = Pockercard.on_deck_ids.sample(1)[0]
    sourcePlayer_id = Game.last.players.deck.id
    # destPlayer_id = Game.last.players.find_by(user: current_user,role: nil).id
    destPlayer_id = Game.last.players.by_user(current_user).id

    pockerCard_id = targetCard_id    
    command_moveCard(dest_id: destPlayer_id, source_id: sourcePlayer_id, card_id: pockerCard_id)
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

 

end
