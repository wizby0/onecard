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
        $('#chatting-info-items').html('') #보내기전에 내용 전부다 지우기  
        for player in data.players
          appendSystemUserListItem(player)
        appendSystemMessage(data.count_number)

      else if data.system_info == "cards_lists"
        $('#card-info-items').html('') #보내기전에 내용 전부다 지우기  
        for card in data.cards
          appendSystemCardListItem(card)

      else if data.system_info == "pockers_lists"
        for pocker in data.pockers
          appendSystemPockerListItem(pocker)

      else if data.system_info == "lists_end"
          appendSystemEndListItem(data.list_info)

          
      



  speak: (msg) ->
    @perform 'speak', message: msg

  user_join: ->
    @perform 'user_join'
    
  test_function: ->
    @perform 'test_function'

  test_function2: ->
    @perform 'test_function2'

#sytem info mation temporal functions 

  appendTestMessage = ()->
      $('#messages').append("test")

  appendMessage = (message) ->
      $('#messages').append(message)

  appendSystemMessage = (message) ->
    $('#info-messages').html(message)

  appendSystemAnounce = (message) ->
    $('#messages').append(message + '<br>')

  appendSystemUserListItem = (userListItem) ->
    itemHtmlString = 
      '<div>' + userListItem.index + ' ' + userListItem.name + ' [' + userListItem.status + ']' +
      '</div>'

    $('#user-info-items').append(itemHtmlString)

  appendSystemCardListItem = (cardListItem) ->
    itemHtmlString = 
      '<div>' + cardListItem.index + 'num= <' + cardListItem.count_card + '>' +
      '</div>'

    $('#card-info-items').append(itemHtmlString)


  appendSystemPockerListItem = (pockerListItem) ->
    itemHtmlString = 
      '<span>' + ' ' + pockerListItem.index + '=[' + pockerListItem.shape + ' ' + pockerListItem.number + '] ' + '</span>'

    $('#card-info-items').append(itemHtmlString)

  appendSystemEndListItem = (ListItem) ->
    itemHtmlString = 
      '<div>' + 'user' + ListItem.pockers_number + 'total=' + ListItem.pockers_number +
      '</div>'
    $('#card-info-items').append(itemHtmlString)

$(document).on 'keypress', '#chat-speak', (event) ->
  if event.keyCode is 13
    App.chat.speak(event.target.value)
    event.target.value = ""
    event.preventDefault()

$(document).on 'click', '#test_function', ->
  App.chat.test_function()

$(document).on 'click', '#test_function2', ->
  App.chat.test_function2()