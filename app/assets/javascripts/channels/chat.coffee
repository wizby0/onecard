App.chat = App.cable.subscriptions.create "ChatChannel",
  connected: ->
    # Called when the subscription is ready for use on the server
    this.user_join()

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    # Called when there's incoming data on the websocket for this channel

    if data.message?
        appendMessage(data.message)

    if data.system_info?
      if data.system_info == "user_join"
        appendSystemAnounce(data.user_info.name + "님이 참여하셨습니다.")

      else if data.system_info == "players_lists"
        appendSystemMessage(data.count_number)


  speak: (msg) ->
    @perform 'speak', message: msg

  user_join: ->
    @perform 'user_join'
    
  test_function: ->
    @perform 'test_function'

#sytem info mation temporal functions 

  appendMessage = (message) ->
      $('#messages').append(message)

  appendSystemMessage = (message) ->
    $('#info-messages').html(message)

  appendSystemAnounce = (message) ->
    $('#messages').append(message + '<br>')

$(document).on 'keypress', '#chat-speak', (event) ->
  if event.keyCode is 13
    App.chat.speak(event.target.value)
    event.target.value = ""
    event.preventDefault()

$(document).on 'click', '#test_function', ->
  App.chat.test_function()