Meteor.publish 'myMessages', ->
  Schema.messages.find { $or: [ { sender: @userId }, { receiver: @userId } ] }

Schema.messages.allow
  insert: -> true
  update: -> true
  remove: -> true