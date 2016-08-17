# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class ChatChannel < ApplicationCable::Channel
  @@deck_list = []
  @@dummy_list = []
  @@attack_point =0
  @@last_card_propertiy = []

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
    command_shuffle_all_cards()
    display_cardListInfomessage()
  end

  def command_drawCard 
    action_drawCard()
    display_cardListInfomessage()
    display_userListInfomessage()
  end



  def test_function  
    # display_turnOnPlayer()
    # display_cardListInfomessage()
    # command_endTurn()
    # command_shuffle()
    # display_cardListInfomessage()
    # @@dummy_list.push(1)
    # @@dummy_list.push(7)
    display_lastDummyCard()
  end

  def test_function2  
    # action_endTurn()
    # action_moveCard()
    # display_cardListInfomessage()
    # command_jump()
    # ActionCable.server.broadcast('messages', card_id: @@attack_point ,system_info: "last_card") 
    # ActionCable.server.broadcast('messages', card_id: @@last_card_propertiy[0] ,system_info: "last_card")
    # ActionCable.server.broadcast('messages', card_id: @@last_card_propertiy[1] ,system_info: "last_card")
    check_winOrLose()
  end



  def command_shuffle_all_cards()
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

    seed_card_id = Pockercard.on_deck_ids.sample(1)[0]
    @@dummy_list.clear
    @@dummy_list.push(seed_card_id)
    seed_card = Pockercard.find(seed_card_id)
    seed_card.update(player_id: 2)#seed card for dummy
    action_putBottomCard(seed_card_id)

    top_cards = Pockercard.on_deck_ids.sample(3) #remember top 3 cards
    @@deck_list += top_cards

  end

  def command_moveCard(data)
    action_moveCard(data)
    display_cardListInfomessage()
  end


  def command_shuffle_dummy()
    dummy_card_ids = Pockercard.on_dummy_ids

    
    #TODO extract top two cards of dummy
    dummy_card_ids.delete(@@dummy_list[0])
    dummy_card_ids.delete(@@dummy_list[1])

    Pockercard.where(id: dummy_card_ids).update_all(player_id: 1) #put to deck
    display_cardListInfomessage()
  end

  def command_changeCardShape(data)
    if @@last_card_propertiy[1] == "ready_for7"
      card_shape = data["card_shape"]
      action_changeBottomCard(card_shape)
      action_endTurn(1) #after turn end
    end
  end

  def command_useCard(data)
    card_number = data["card_number"]
    curPlayer_id = Game.last.players.by_user(current_user).id
    myCards_ids = Pockercard.where(player_id:curPlayer_id).order(:id).ids
    targetCard_id = myCards_ids[card_number]

    action_useCard(targetCard_id)

    display_cardListInfomessage()
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
      pockers = Pockercard.where(player_id: player.id).order(:id)
      ActionCable.server.broadcast('messages', list_info: {player_id: player.id, player_name: player_name, pockers_number: count_card} , system_info: "lists_start")
      ActionCable.server.broadcast('messages', pockers_number: count_card, pockers: pockers.each_with_index.map{|pocker, index| { index: pocker.id, shape: pocker.shape, number: pocker.number }}, system_info: "pockers_lists")
      ActionCable.server.broadcast('messages', system_info: "lists_end")    
    end
    display_lastDummyCard()

  end

  def display_turnOnPlayer()
    turnPlayer = Player.where(status:"turn_on").last
    ActionCable.server.broadcast('messages', player_id: turnPlayer.id-2 ,system_info: "turn_on") 
  end

  def display_lastDummyCard()
    # lastCard = @@dummy_list.shift
    lastCard = @@dummy_list[0]
    ActionCable.server.broadcast('messages', card_id: lastCard ,system_info: "last_card") 
    if @@dummy_list.size >1
      lastCard = @@dummy_list[1]
      ActionCable.server.broadcast('messages', card_id: lastCard ,system_info: "last_card") 
    end
  end

  #============ check condition functions ================

  def check_cardOwn(card_id) #authroity

    value_return = false

    if Game.last.players.find_by(user: current_user,role: nil).id == Pockercard.find_by(id:card_id).player_id
      value_return = true
    end

    return value_return
    
  end

  def check_currentTurn()
    value_return = false
    if Game.last.players.find_by(user: current_user,role: nil).id == Game.last.players.where(status:"turn_on").last.id
      value_return = true
    end

    # value_return = true #for test

    return value_return
  end

  def check_usableNumShape(card_id)
    value_return = false

    if @@last_card_propertiy[0] == "JOCKER"
      return true
    end

    if Pockercard.find(card_id).number == @@last_card_propertiy[0] #number
      value_return = true
    elsif Pockercard.find(card_id).shape == @@last_card_propertiy[1] #shape
      value_return = true
    end
    # value_return = true #for test
    return value_return
  end


  def check_winOrLose()

    alive_players = Game.last.players.on_game.order(:id)

    alive_players.each do |player|
      count_cards = check_ownCardsCount(player.id)
      end_player_id = player.id 
      if count_cards >= 20
        game_result = "lose"
        Game.last.players.find(end_player_id).update(status:game_result)
        ActionCable.server.broadcast('messages', player_id: end_player_id-2 ,status: game_result ,system_info: "win_or_lose")
      elsif count_cards == 0
        game_result = "win"
        Game.last.players.find(end_player_id).update(status:game_result)
        ActionCable.server.broadcast('messages', player_id: end_player_id-2 ,status: game_result ,system_info: "win_or_lose")
      else
        ActionCable.server.broadcast('messages', player_id: end_player_id-2 ,status: "yet alive" ,system_info: "win_or_lose")  
      end
      
    end

  end

  def check_ownCardsCount(game_player_id)
    card_count = Pockercard.where(player_id: game_player_id).count
    return card_count
  end


  #=============== partial action functions =================


  def action_useCard(pockerCard_id)

    if check_cardOwn(pockerCard_id) and check_currentTurn()#only owner can play card and current turn on
      if check_usableNumShape(pockerCard_id) #check bottom number and shape

        sourcePlayer_id = Game.last.players.by_user(current_user).id
        destPlayer_id = Game.last.players.dummy.id # destPlayer_id = 2 (dummy)          

        action_moveCard(dest_id: destPlayer_id, source_id: sourcePlayer_id, card_id: pockerCard_id)

        #check effect of cards
        card_effect = Pockercard.find(pockerCard_id).effect
        action_addDummyList(pockerCard_id)
        action_putBottomCard(pockerCard_id)
        if card_effect == "none"
          action_endTurn(1) #move to next player=[
        elsif card_effect == "back"     
          Game.last.toggle_order!
          action_endTurn(1) #skip next player
        elsif card_effect == "jump"  
          action_endTurn(2) #move to next next player
        elsif card_effect == "attack"
          action_attackCard(pockerCard_id)
          action_endTurn(1) #move to next next player
        elsif card_effect == "change"
          action_setBottomCardStep()
        elsif card_effect == "onemore" 
        else
          action_endTurn(1) #skip next player
        end
        check_winOrLose()     
      end
    end



  end

  def action_drawCard()
    if check_currentTurn()
      if @@attack_point > 0 #attaked by previous player
        card_amount = @@attack_point
        @@attack_point =0
      else                  #normal peaceful draw
        card_amount = 1
      end


      sourcePlayer_id = Game.last.players.deck.id
      destPlayer_id = Game.last.players.by_user(current_user).id
      while(card_amount>0) 

        targetCard_id = Pockercard.on_deck_ids.sample(1)[0]


        @@deck_list.push(targetCard_id)
        targetCard_id = @@deck_list.shift      
        pockerCard_id = targetCard_id    
        action_moveCard(dest_id: destPlayer_id, source_id: sourcePlayer_id, card_id: pockerCard_id)

        if Pockercard.on_deck_ids.length < 4 #if cards number is less than 4
          command_shuffle_dummy()
        end
        card_amount-=1
      end
      action_endTurn(1)
      check_winOrLose()
    end

  end

  def action_addDummyList(targetCard_id)

    if(@@dummy_list.first != targetCard_id)
      if(@@dummy_list.size >1)
        @@dummy_list.pop
      end
      @@dummy_list.unshift(targetCard_id)      
    end
  end

  def action_attackCard(targetCard_id)
    card_number = Pockercard.find(targetCard_id).number
    card_shape = Pockercard.find(targetCard_id).shape
    Pockercard.find(1).number
    if card_number == "2"
      @@attack_point+=2
    elsif card_number == "A"
        if card_shape == "spade" #spade A
          @@attack_point+=5
        else
          @@attack_point+=3
        end
      elsif card_number == "JOCKER"
        if card_shape == "color" #spade A
          @@attack_point+=13
        else
          @@attack_point+=10
        end
      end

    end

    def action_putBottomCard(card_id)
      bottom_card = Pockercard.find(card_id)
      @@last_card_propertiy.clear
      @@last_card_propertiy.push(bottom_card.number)
      @@last_card_propertiy.push(bottom_card.shape)
    end

    
    def action_setBottomCardStep()
      @@last_card_propertiy[1] = "ready_for7"
    end
    def action_changeBottomCard(want_shape)
      if @@last_card_propertiy[1] == "ready_for7"
        @@last_card_propertiy[1]= want_shape
      end
      
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
