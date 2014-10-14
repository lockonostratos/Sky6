Sky.template.extends Template.notificationDetails,
  notifications: -> Sky.global.notification.notifications
  unreadNotifications: -> Sky.global.notification.unreadNotifications

  requestSenderAvatar: ->
    profile = Schema.userProfiles.findOne({user: @sender})
    return undefined if !profile?.avatar
    AvatarImages.findOne(profile.avatar)?.url()
  requestSenderAlias: ->
    Schema.userProfiles.findOne({user: @sender})?.fullName ? '?'
