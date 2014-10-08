Sky.global.notification = {}

Meteor.startup ->
  Sky.global.notification.all = Schema.notifications.find()

  #Notify types -----------------------------------------------------
  Sky.global.notification.notifies = Schema.notifications.find
    notificationType: Sky.notificationTypes.notify.key
  Sky.global.notification.unreadNotifies = Schema.notifications.find
    seen: false
    notificationType: Sky.notificationTypes.notify.key

  #Event types ------------------------------------------------------
  Sky.global.notification.events = Schema.notifications.find
    notificationType: Sky.notificationTypes.event.key
  Sky.global.notification.unreadEvents = Schema.notifications.find
    seen: false
    notificationType: Sky.notificationTypes.event.key

  #Request types ------------------------------------------------------
  Sky.global.notification.requests = Schema.notifications.find
    notificationType: Sky.notificationTypes.request.key
  Sky.global.notification.unreadRequests = Schema.notifications.find
    seen: false
    notificationType: Sky.notificationTypes.request.key