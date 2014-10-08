Meteor.startup ->
  Sky.global.allMessages = Messenger.allMessages()
  Sky.global.currentMessages = Messenger.currentMessages()

  messengerTracker = Tracker.autorun ->
    Session.set 'unreadMessages', Messenger.unreads().fetch()
    Session.set 'incommingMessages', Messenger.incommings().fetch()