Schema.add 'messages', class Messenger
  @say: (message, receiver) ->
    Schema.messages.insert
      sender: Meteor.userId()
      receiver: receiver
      message: message
  @read: (messageId) ->
    currentMessage = Schema.message.findOne(messageId)
    return if !currentMessage

    Schema.messagescurrentMessage._id