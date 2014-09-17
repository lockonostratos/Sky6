Schema.add 'messages', class Messenger
  @say: (message, receiver) ->
    @schema.insert
      sender: Meteor.userId()
      receiver: receiver
      message: message

  @read: (messageId) ->
    currentMessage = @schema.findOne(messageId)
    return if !currentMessage

  @unreads: ->
    @schema.find({reads: {$ne: Meteor.userId()}, sender: {$ne: Meteor.userId()}})

#    Schema.messages.update(currentMessage._id, {$set: {}})