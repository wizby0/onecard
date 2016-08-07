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
    render_userListInfomessage()
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
    # player = Game.last.player
    # count_number = Player.where(game_id: Game.last.id).count
    # ActionCable.server.broadcast('messages', players: player.each_with_index.map{|mapium, index| { index: index+1, name: player.user.name, status: player.status }},count_number: Player.where(game_id: Game.last.id).count, system_info: "players_lists")
    ActionCable.server.broadcast('messages', count_number: Player.where(game_id: Game.last.id).count, system_info: "players_lists")
  end


end
