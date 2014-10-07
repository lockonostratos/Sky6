Schema.add 'customers', class Customer
  destroy: ->
    userProfile = Schema.userProfiles.findOne({user: Meteor.userId()})
    if userProfile
      sale = Schema.sales.findOne({parentMerchant: userProfile.parentMerchant,buyer: @id})
      if !sale then Schema.customers.remove(@id)
    else
      console.log 'Loi khong tim thay userProfile'