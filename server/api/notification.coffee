Meteor.methods
  sendNotificationOptional: (message, receiver, product, notificationGroup, notificationType = Sky.notificationTypes.notify.key) ->
    newNotification = {
      sender  : Meteor.userId()
      receiver: receiver
      message : message
      product : product
      group   : notificationGroup
      notificationType: notificationType
    }
    findOldNotification = Schema.notifications.findOne({
      sender  : newNotification.sender
      receiver: newNotification.receiver
      product : newNotification.product
      group   : newNotification.group
      notificationType  : newNotification.notificationType})
    console.log findOldNotification
    if findOldNotification
      Schema.notifications.update findOldNotification._id, $set:{message: newNotification.message}
    else
      Schema.notifications.insert newNotification