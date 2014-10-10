Sky.template.extends Template.myAvatarItem,
  avatarImageSrc: -> AvatarImages.findOne(@avatar)?.url()
  avatarLetter: ->
    fullAlias = @fullName ? Meteor.users.findOne(@user)?.emails[0].address
    fullAlias?.split(' ').pop().substring(0,1)
  fullAlias: ->
    fullAlias = @fullName ? Meteor.users.findOne(@user)?.emails[0].address
    Sky.helpers.shortName(fullAlias)
  isOnline: -> if Meteor.users.findOne(@user)?.status?.online then 'active' else ''

  events:
    "click": (event, template) -> console.log template.find('.avatarFileSelector').click()
    "change .avatarFileSelector": ->
      currentProfile = Session.get('currentProfile')
      AvatarImages.findOne(currentProfile.avatar)?.remove()

      files = event.target.files
      if files.length > 0
        AvatarImages.insert files[0], (error, fileObj) ->
          console.log error, fileObj
          Schema.userProfiles.update(currentProfile._id, {$set: {avatar: fileObj._id}})