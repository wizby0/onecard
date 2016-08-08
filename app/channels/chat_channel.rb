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

    count_cards = []
    players = Player.where(game_id:Game.last.id)
    players.each_with_index do |player, index|
      count_cards[index] = Pockercard.where(player_id:player.id).count
    end
    
    ActionCable.server.broadcast('messages', cards: count_cards.each_with_index.map{|count_card, index| { index: index+1, count_card: count_card }}, system_info: "cards_lists")
    

  


 

    # cards = Pockercard.where(player_id:Player.last.id)
    # count_number = Player.where(game_id: Game.last.id, role: nil).count #count player except deck and dummy
    # ActionCable.server.broadcast('messages', players: players.each_with_index.map{|player, index| { index: index+1, name: player.user.name, status: player.status }}, count_number: count_number, system_info: "players_lists")
    
  end

end
