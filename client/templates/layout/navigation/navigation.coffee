Sky.appTemplate.extends Template.navigation,
  unreadMessageCount: -> Sky.global.notification.unreadMessages.count()
  messageClass: -> if Sky.global.notification.unreadMessages.count() > 0 then 'active' else ''

  unreadNotificationCount: -> Sky.global.notification.unreadNotifications.count()
  notificationClass: -> if Sky.global.notification.unreadNotifications.count() > 0 then 'active' else ''

  unreadRequestCount: -> Sky.global.notification.unreadRequests.count()
  requestClass: -> if Sky.global.notification.unreadRequests.count() > 0 then 'active' else ''

  routeHistory: -> Session.get('routeHistory')
  currentSystemVersion: -> Schema.systems.findOne()?.version ? ''

#  ui:
#    unreadMessagePopover: "#unreadMessagePopover"
#
#  rendered: ->
#    $(@ui.unreadMessagePopover).modalPopover
#      target: '#unreadMessageHandler'
#      backdrop: true
#      placement: 'bottom'

#  events:
#    "click #unreadMessageHandler": (event, template) ->
#      Messenger.read(message._id) for message in Session.get('unreadMessages')
#      $(template.ui.unreadMessagePopover).modalPopover('show')