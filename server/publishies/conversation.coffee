Meteor.publish 'myMessages', ->
  Schema.messages.find { $or: [ { sender: @userId }, { receiver: @userId } ] }