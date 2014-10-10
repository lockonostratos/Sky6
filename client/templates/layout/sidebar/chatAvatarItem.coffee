Sky.template.extends Template.chatAvatarItem,
  avatarImageSrc: -> AvatarImages.findOne(@avatar)?.url()
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