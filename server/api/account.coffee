Meteor.methods
  setPassword: (userId, newPassword) ->
    Accounts.setPassword(userId, newPassword)
    console.log 'password has changed'

#  createMerchantAccount: (email, password, profileOptions) ->
#    console.log "unknown!"
#    creator = Meteor.userId()
#    #Checking permission....
#    return if !creator
#
#    newUserId = Accounts.createUser(email, password)
#    console.log "the user #{creator} has created an account for his merchant: #{email}"

#    profileOptions.user = newUserId
#    profileOptions.creator = Meteor.userId()
#    profileOptions.isRoot = false
#
#    console.log "profileOptions ", profileOptions
#
#    Schema.profiles.insert profileOptions
    #newUser.update()

  createMerchantAccount: (email, password, profile) ->
    creator = Meteor.userId()
    #Checking permission....
    return if !creator

    newUserId = Accounts.createUser({email: email, password: password})
    console.log "the user #{creator} has created an account for his merchant: #{email}"
    #newUser.update()

    profile.user = newUserId
    profile.creator = Meteor.userId()
    profile.isRoot = false

    Schema.userProfiles.insert profile, (error, result)->
      if error
        console.log error
      else
        MetroSummary.updateMetroSummaryBy(['staff'])

  updateAccount: (options) ->
    Meteor.users.update(Meteor.userId(), {$set: options})