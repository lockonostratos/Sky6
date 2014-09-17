Sky.template.extends Template.unreadMessagePopover,
  incommingMessages: -> Session.get('incommingMessages') ? []
  senderEmail: -> Meteor.users.findOne(@sender)?.emails[0]?.address ? 'Not found'