Sky.template.extends Template.unreadMessagePopover,
  unreadMessages: -> Session.get('unreadMessages') ? []