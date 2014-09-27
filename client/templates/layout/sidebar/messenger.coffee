scrollDownIfNecessary = ($element, instance, timeHook) ->
  if instance.version?.createdAt > timeHook and instance.sender is Session.get('currentChatTarget')
    $element.slimScroll({ scrollBy: '999999px' })
playSoundIfNecessary = (instance, timeHook) ->
  if instance.version?.createdAt > timeHook
    createjs.Sound.play("sound")

messengerDeps = new Tracker.Dependency
getCurrentMessages = ->
  messengerDeps.depend()
  Sky.global.currentMessages

initTracker = ->
  return if Sky.global.messengerTracker
  Sky.global.messengerTracker = Tracker.autorun ->
    if Session.get('currentProfile') and Session.get('currentChatTarget')
      messengerDeps.changed()
      Sky.global.currentMessages = Messenger.currentMessages(Session.get('currentChatTarget'))

Sky.template.extends Template.messenger,
  currentMessages: -> getCurrentMessages()
  visibilityClass: -> if Session.get('messengerVisibility') then 'show' else 'hide'
  messageClass: -> if @sender is Meteor.userId() then 'my-message' else 'friend-message'
  targetAlias: ->
    fullName = Schema.userProfiles.findOne({user: Session.get('currentChatTarget')})?.fullName
    email = Meteor.users.findOne(Session.get('currentChatTarget'))?.emails[0]?.address
    fullName ? email

  ui:
    messages: "ul.messages"

  created: -> initTracker()

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
        $messages.slimScroll({ scrollBy: '999999px' })
