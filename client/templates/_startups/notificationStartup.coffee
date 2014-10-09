Sky.global.notification = {}
sentByMe = {sender: Meteor.userId()}
sendToMe = {receiver: Meteor.userId()}
unread   = {reads: {$ne: Meteor.userId()}}

Meteor.startup ->
  Sky.global.notification.all = Schema.notifications.find()

  #Notify types -----------------------------------------------------
  Sky.global.notification.notifications = Schema.notifications.find { isRequest: false }, {sort: {'version.createdAt': -1}}
  Sky.global.notification.unreadNotifications = Schema.notifications.find { isRequest: false, seen: false }

  #Request types ------------------------------------------------------
  Sky.global.notification.requests = Schema.notifications.find { isRequest: true }, {sort: {'version.createdAt': -1}}
  Sky.global.notification.unreadRequests = Schema.notifications.find { isRequest: true, seen: false }

  #Messengers
  Sky.global.notification.top10messages = Schema.messages.find { $or: [sentByMe, sendToMe] }, {sort: {'version.createdAt': -1}, limit: 10}
  Sky.global.notification.unreadMessages = Schema.messages.find { $and: [sendToMe, unread] }

  #Event types ------------------------------------------------------
#  Sky.global.notification.events = Schema.notifications.find
#    notificationType: Sky.notificationTypes.event.key
#  Sky.global.notification.unreadEvents = Schema.notifications.find
#    seen: false
#    notificationType: Sky.notificationTypes.event.key
