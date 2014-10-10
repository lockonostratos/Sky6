Sky.template.extends Template.chatAvatarItem,
  shortAlias: ->
    fullAlias = @fullName ? Meteor.users.findOne(@user)?.emails[0].address
    Sky.helpers.shortName(fullAlias)
  avatarUrl: -> if @avatar then AvatarImages.findOne(@avatar)?.url() else undefined
  isOnline: -> if Meteor.users.findOne(@user)?.status?.online then 'active' else ''
  hasUnreadMessage: ->
    return '' if @user is Meteor.userId()
    result = Schema.messages.findOne { $and: [{sender: @user}, {reads: {$ne: Meteor.userId()}}] }
    if result then 'active' else ''