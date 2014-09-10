Meteor.methods
  setPassword: (userId, newPassword) ->
    Accounts.setPassword(userId, newPassword)
    console.log 'password has changed'

  addMerchantAccount: (merchantId, email, password) ->
    creator = Meteor.userId()
    #Checking permission....
    return if !creator

    newUser = Accounts.createUser({email: email, password: password})
    console.log "the user #{creator} has created an account for his merchant: #{email}"
    #newUser.update()