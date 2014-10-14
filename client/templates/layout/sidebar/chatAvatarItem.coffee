Sky.template.extends Template.chatAvatarItem,
  shortAlias: ->
    fullAlias = @fullName ? Meteor.users.findOne(@user)?.emails[0].address
    Sky.helpers.shortName(fullAlias)
  avatarUrl: -> if @avatar then AvatarImages.findOne(@avatar)?.url() else undefined
  onlineStatus: ->
    currentUser = Meteor.users.findOne(@user)
    if currentUser?.status?.online
      return 'online'
    else if currentUser?.status?.idle
      return 'idle'
    else
      return 'offline'

  hasUnreadMessage: ->
    return '' if @user is Meteor.userId()
    result = Schema.messages.findOne { $and: [{sender: @user}, {reads: {$ne: Meteor.userId()}}] }
    if result then 'active' else ''