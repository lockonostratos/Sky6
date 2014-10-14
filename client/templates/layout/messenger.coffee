scrollDownIfNecessary = ($element, instance, timeHook) ->
  if instance.version?.createdAt > timeHook and instance.sender is Session.get('currentChatTarget')
#    $element.slimScroll({ scrollBy: '999999px' })
    $element.scrollTop($element[0].scrollHeight)
    console.log 'missing function, we must implement scroll to bottom here!'

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
  visibilityClass: -> if Session.get('messengerVisibility') then 'active' else ''
  messageClass: -> if @sender is Meteor.userId() then 'me' else 'friend'
  friendMessage: -> @sender isnt Meteor.userId()
  minimizedClass: -> Session.get('messengerMinimize')
  targetAvatar: ->
    profile = Schema.userProfiles.findOne({user: Session.get('currentChatTarget')})
    return undefined if !profile?.avatar
    AvatarImages.findOne(profile.avatar)?.url()

  targetAlias: ->
    fullName = Schema.userProfiles.findOne({user: Session.get('currentChatTarget')})?.fullName
    email = Meteor.users.findOne(Session.get('currentChatTarget'))?.emails[0]?.address
    fullName ? email

  ui:
    messages: ".all-messages"
    messenger: "#messenger"

  created: ->
    initTracker()
    Session.set('messengerMinimize', 'minimized')

  rendered: ->
    $messages = $(@ui.messages)
    thisTime = Date.now()

    Sky.global.incomingObserver = Sky.global.allMessages.observeChanges
      added: (id, instance) ->
        scrollDownIfNecessary($messages, instance, thisTime)
        playSoundIfNecessary(instance, thisTime)

#    $(@ui.messenger).bind('dragstart', (event) -> $(event.target).is('.header'))
#    .bind('drag', (event) ->
#      maxOffset = $(document).height() - $(@).outerHeight() + 15
#      $(@).css({top: event.clientY - 15}) if 58 < event.clientY < maxOffset
#    )

  destroyed: -> Sky.global.incomingObserver.stop()

  events:
#    "click .close-btn": -> Session.set('messengerVisibility', false)
    "click ul.messages": (event, template) ->
      $(template.find('input')).focus()
    "keypress input": (event, template) ->
      $element = $(event.target)
      $messages = $(template.ui.messages)
      message = $element.val()
      if event.which is 13 and message.length > 0 and Session.get('currentChatTarget')
        Messenger.say message, Session.get('currentChatTarget')
        $element.val('')
    "keyup input": (event, template) ->
      if event.which is 27 then Session.set('messengerVisibility', false)
    "focus input": ->
      Messenger.read(message._id) for message in Session.get('unreadMessages') when message.sender is Session.get('currentChatTarget')
      Session.set('messengerMinimize', 'maximized')
    "focusout input": -> Session.set('messengerMinimize', 'minimized')