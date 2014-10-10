Sky.template.extends Template.messageNotifications,
  top10messages: -> Sky.global.notification.top10messages
  unreadMessages: -> Sky.global.notification.unreadMessages

  requestSenderAvatar: ->
    profile = Schema.userProfiles.findOne({user: @sender})
    return undefined if !profile?.avatar
    AvatarImages.findOne(profile.avatar)?.url()
  requestSenderAlias: ->
    console.log @sender
    Schema.userProfiles.findOne({user: @sender})?.fullName ? '?'
