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
    render_userListInfomessage()
  end
  

  def test_function  
    render_cardListInfomessage()
  end

  def test_function2  

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

 def render_userListInfomessage()

    # players = Player.where(game_id:Game.last.id)
    players = Game.last.players
    count_number = Player.where(game_id: Game.last.id, role: nil).count #count player except deck and dummy
    ActionCable.server.broadcast('messages', players: players.each_with_index.map{|player, index| { index: index+1, name: player.user.name, status: player.status }}, count_number: count_number, system_info: "players_lists")
    
  end


  def render_cardListInfomessage()
    ActionCable.server.broadcast('messages', system_info: "claer_list")   
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

end
