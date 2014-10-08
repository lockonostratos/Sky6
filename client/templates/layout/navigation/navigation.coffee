Sky.appTemplate.extends Template.navigation,
  unreadMessageCount: -> Session.get('unreadMessages')?.length ? 0
  messageClass: -> if Session.get('unreadMessages')?.length > 0 then 'active' else ''

  unreadNotifyCount: -> Sky.global.notification.unreadNotifies.count()
  notifyClass: -> if Sky.global.notification.unreadNotifies?.count() > 0 then 'active' else ''

  unreadEventCount: -> Sky.global.notification.unreadEvents.count()
  eventClass: -> if Sky.global.notification.unreadEvents?.count() > 0 then 'active' else ''

  unreadRequestCount: -> Sky.global.notification.unreadRequests.count()
  requestClass: -> if Sky.global.notification.unreadRequests?.count() > 0 then 'active' else ''

  routeHistory: -> Session.get('routeHistory')
  currentSystemVersion: -> Schema.systems.findOne()?.version ? ''

  ui:
    unreadMessagePopover: "#unreadMessagePopover"

  rendered: ->
    $(@ui.unreadMessagePopover).modalPopover
      target: '#unreadMessageHandler'
      backdrop: true
      placement: 'bottom'

  events:
    "click #unreadMessageHandler": (event, template) ->
      Messenger.read(message._id) for message in Session.get('unreadMessages')
      $(template.ui.unreadMessagePopover).modalPopover('show')