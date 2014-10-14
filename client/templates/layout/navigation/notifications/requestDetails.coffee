Sky.template.extends Template.requestDetails,
  requests: -> Sky.global.notification.requests
  unreadRequests: -> Sky.global.notification.unreadRequests

  requestSenderAvatar: ->
    profile = Schema.userProfiles.findOne({user: @sender})
    return undefined if !profile?.avatar
    AvatarImages.findOne(profile.avatar)?.url()
  requestSenderAlias: ->
    Schema.userProfiles.findOne({user: @sender})?.fullName ? '?'
