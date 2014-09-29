Sky.template.extends Template.chatAvatarItem,
  myAvatar: -> if @user is Meteor.userId() then 'me' else ''
  avatar: ->
    if Meteor.userId() is @user then 'avatar'
    else @avatar

  avatarLetter: ->
    fullAlias = @fullName ? Meteor.users.findOne(@user)?.emails[0].address
    fullAlias?.split(' ').pop().substring(0,1)
  fullAlias: ->
    fullAlias = @fullName ? Meteor.users.findOne(@user)?.emails[0].address
    Sky.helpers.shortName(fullAlias)
  isOnline: -> if Meteor.users.findOne(@user)?.status?.online then 'active' else ''
  hasUnreadMessage: ->
    return '' if @user is Meteor.userId()
    result = Schema.messages.findOne { $and: [{sender: @user}, {reads: {$ne: Meteor.userId()}}] }
    if result then 'active' else ''