scrollDownIfNecessary = ($element, instance, timeHook) ->
  if instance.version?.createdAt > timeHook and instance.sender is Session.get('currentChatTarget')
    $element.slimScroll({ scrollBy: '99999px' })
playSoundIfNecessary = (instance, timeHook) ->
  if instance.version?.createdAt > timeHook
    createjs.Sound.play("sound")


Sky.template.extends Template.messenger,
  currentConversation: -> Sky.global.currentMessages
  visibilityClass: -> if Session.get('messengerVisibility') then 'show' else 'hide'
  messageClass: -> if @sender is Meteor.userId() then 'my-message' else 'friend-message'

  ui:
    messages: "ul.messages"

  rendered: ->
    $messages = $(@ui.messages)
    thisTime = Date.now()

    $(@ui.messages).slimScroll
      height: '245px'
      start: 'bottom'

    Sky.global.incomingObserver = Sky.global.allMessages.observeChanges
      added: (id, instance) ->
        scrollDownIfNecessary($messages, instance, thisTime)
        playSoundIfNecessary(instance, thisTime)


  destroyed: -> Sky.global.incomingObserver.stop()

  events:
    "click a.close-btn": -> Session.set('messengerVisibility', false)
    "keypress input": (event, template) ->
      $element = $(event.target)
      $messages = $(template.ui.messages)
      message = $element.val()
      if event.which is 13 and message.length > 0 and Session.get('currentChatTarget')
        Messenger.say message, Session.get('currentChatTarget')
        $element.val('')
        $messages.slimScroll({ scrollBy: '99999px' })
