Meteor.publish 'myNotifications', ->
  Schema.notifications.find { receiver: @userId }

Schema.notifications.allow
  insert: -> true
  update: -> true
  remove: -> true