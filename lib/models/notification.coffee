Schema.add 'notifications', class Notification
  @send: (message, receiver, notificationType = Sky.notificationTypes.notify.key) ->
    newNotification = {
      sender: Meteor.userId()
      receiver: receiver
      message: message
      notificationType: notificationType
    }

    @schema.insert newNotification