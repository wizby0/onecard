# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class ChatChannel < ApplicationCable::Channel

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
    # ActionCable.server.broadcast('messages', user_info: { name: current_user.name, count_number: Player.where(game_id: Game.last.id).count}, system_info: "user_join")
    display_userListInfomessage()
    display_cardListInfomessage()
  end
  

  def test_function  
    display_turnOnPlayer()
  end

  def test_function2  
    action_turnEnd()
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
       username: current_user
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
      ActionCable.server.broadcast('messages', pockers_number: count_card, pockers: pockers.each_with_index.map{|pocker, index| { index: index+1, shape: pocker.shape, number: pocker.number }}, system_info: "pockers_lists")
      ActionCable.server.broadcast('messages', system_info: "lists_end")    
    end
  
  end

  def display_turnOnPlayer()
    turnPlayer = Player.where(status:"turn_on").last
    ActionCable.server.broadcast('messages', player_id: turnPlayer.id-2 ,system_info: "turn_on") 
  end

  def action_turnEnd()

    turn_step = 1 #default step
    game_id = Game.last.id

    turnPlayer = Player.where(game_id: game_id, status:"turn_on").last
    alivePlayers = Player.where(game_id: game_id, status:["alive","turn_on"]) #alive player's id

    turnPlayer_index =0  #init
    nextTurn_index =0  #init

    alivePlayers.each_with_index do |alivePlayer, index|  #find out index in alive player array (not id)
      if alivePlayer.user_id == turnPlayer.user_id
        turnPlayer_index = index
      end
    end
    max_index = alivePlayers.count

    if Game.last.play_order == "clock_wise"   #move index for 1 step
      nextTurn_index = turnPlayer_index + turn_step
    else
      nextTurn_index = turnPlayer_index - turn_step
    end

    if nextTurn_index < 0           #check underflow
      nextTurn_index += max_index
    end

    if nextTurn_index >= max_index  #check overflow
      nextTurn_index -= max_index
    end

    Player.find(alivePlayers[turnPlayer_index].id).update(status: "alive") #change active player to deactive
    Player.find(alivePlayers[nextTurn_index].id).update(status: "turn_on") #change active player to deactive
        
  end

end
