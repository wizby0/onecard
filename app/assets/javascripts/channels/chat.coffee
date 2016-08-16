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

      else if data.system_info == "clear_list"
        $('#card-info-items').html('') #보내기전에 내용 전부다 지우기 

      else if data.system_info == "lists_start"
        appendSystemStartListItem(data.list_info)

      else if data.system_info == "lists_end"
        appendSystemEndListItem()

      else if data.system_info == "turn_on"
        $('#chatting-info-items').html('') #보내기전에 내용 전부다 지우기  
        appendSystemTurnListItem(data.player_id)

      else if data.system_info == "last_card"
        $('#chatting-info-items').html('') #보내기전에 내용 전부다 지우기  
        appendSystemTurnListItem(data.card_id)



  speak: (msg) ->
    @perform 'speak', message: msg

  user_join: ->
    @perform 'user_join'

  test_function: ->
    @perform 'test_function'
    
  test_function2: ->
    @perform 'test_function2'

  move_card: ->
    @perform 'move_card'

  draw_card: ->
    @perform 'command_drawCard'

  start_game: ->
    @perform 'command_start'

  shuffle_cards: ->
    @perform 'command_shuffle_dummy'


  use_card:(card_num) ->
    @perform 'command_useCard', card_number: card_num


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
      '<div style="height: 100px;" class ="'+ pockerListItem.shape + '_' + pockerListItem.number+ '">' +'</div>' +'</div>' 

    $('#card-info-items').append(itemHtmlString)

  appendSystemStartListItem = (ListItem) ->
    itemHtmlString = 
      '<div>' + 'user ' + ListItem.player_name + ' total=' + ListItem.pockers_number +
      '</div>' + '<div>'
    $('#card-info-items').append(itemHtmlString)

  appendSystemEndListItem = () ->
    itemHtmlString ='</div>'
    $('#card-info-items').append(itemHtmlString)

  appendSystemTurnListItem = (current_turn_player) ->
    turnOnString = '<div>' + 'current turn player id =' + current_turn_player + '</div>'
    $('#user-info-items').append(turnOnString)

  appendSystemTurnListItem = (current_last_card) ->
    turnOnString = '<div>' + 'current last card id =' + current_last_card + '</div>'
    $('#user-info-items').append(turnOnString)

$(document).on 'keypress', '#chat-speak', (event) ->
  if event.keyCode is 13
    App.chat.speak(event.target.value)
    event.target.value = ""
    event.preventDefault()

$(document).on 'click', '#test_function', ->
  App.chat.test_function()

$(document).on 'click', '#test_function2', ->
  App.chat.test_function2()

$(document).on 'click', '#draw_card', ->
  App.chat.draw_card()

$(document).on 'click', '#start_game', ->
  App.chat.start_game()

$(document).on 'click', '#shuffle_cards', ->
  App.chat.shuffle_cards()



$(document).on 'click', '#card1', ->
  App.chat.use_card(0)

$(document).on 'click', '#card2', ->
  App.chat.use_card(1)

$(document).on 'click', '#card3', ->
  App.chat.use_card(2)

$(document).on 'click', '#card4', ->
  App.chat.use_card(3)

$(document).on 'click', '#card5', ->
  App.chat.use_card(4)

$(document).on 'click', '#card6', ->
  App.chat.use_card(5)

$(document).on 'click', '#card7', ->
  App.chat.use_card(6)

$(document).on 'click', '#card8', ->
  App.chat.use_card(7)