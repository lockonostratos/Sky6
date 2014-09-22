Meteor.methods
  setPassword: (userId, newPassword) ->
    Accounts.setPassword(userId, newPassword)
    console.log 'password has changed'

  createMerchantAccount: (options) ->
    creator = Meteor.userId()
    #Checking permission....
    return if !creator

    newUser = Accounts.createUser(options)
    console.log "the user #{creator} has created an account for his merchant: #{email}"
    #newUser.update()

  updateAccount: (options) ->
    Meteor.users.update(Meteor.userId(), {$set: options})