Sky.template.extends Template.myAvatarItem,
  avatarUrl: -> if @avatar then AvatarImages.findOne(@avatar)?.url() else undefined
  onlineStatus: ->
    currentUser = Meteor.users.findOne(@user)
    if currentUser?.status?.online
      return 'online'
    else if currentUser?.status?.idle
      return 'idle'
    else
      return 'offline'

  events:
    "click": (event, template) -> console.log template.find('.avatarFileSelector').click()
    "change .avatarFileSelector": (event, template)->
      currentProfile = Session.get('currentProfile')
      files = event.target.files
      if files.length > 0
        AvatarImages.insert files[0], (error, fileObj) ->
          Schema.userProfiles.update(currentProfile._id, {$set: {avatar: fileObj._id}})
          AvatarImages.findOne(currentProfile.avatar)?.remove()