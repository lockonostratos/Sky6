Schema.add 'messages', class Messenger
  @helpers:
    senderInstance: ->
      Meteor.users.findOne(@sender)

  @say: (message, receiver) ->
    @schema.insert
      sender: Meteor.userId()
      receiver: receiver
      message: message

  @read: (messageId) ->
    currentMessage = @schema.findOne(messageId)
    return if !currentMessage
    @schema.update(messageId, {$push: {reads: Meteor.userId()}})

  @readAll: ->
    @schema.update({receiver: Meteor.userId()}, {$push: {reads: Meteor.userId()}})

  @incommings: -> @schema.find({receiver: Meteor.userId()}, {limit: 10})
  @unreads: -> @schema.find({reads: {$ne: Meteor.userId()}, sender: {$ne: Meteor.userId()}})

  @allMessages: -> @schema.find({$or: [{sender: Meteor.userId()}, {receiver: Meteor.userId()}]})
  @currentMessages: (target)->
    console.log 'updated'
    sentByTarget = {sender: target}
    sentToTarget = {receiver: target}
    @schema.find {$or: [sentByTarget, sentToTarget]}