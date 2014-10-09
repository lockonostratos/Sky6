Schema.add 'metroSummaries', class MetroSummary
  @newByMerchant: (merchantId)->
    merchant = Schema.merchants.findOne(merchantId)
    userProfile = Schema.userProfiles.findOne({user: Meteor.userId()})
    if merchant and userProfile
      staffCountMerchant    = Schema.userProfiles.find({currentMerchant: merchant}).count()
      staffCountAll         = Schema.userProfiles.find({parentMerchant: userProfile.parentMerchant}).count()
      customerCountMerchant = Schema.customers.find({currentMerchant: merchant}).count()
      customerCountAll      = Schema.customers.find({parentMerchant: userProfile.parentMerchant}).count()

      option =
        parentMerchant        : userProfile.parentMerchant
        merchant              : merchant._id
        productCount          : 0
        stockCount            : 0
        customerCountAll      : customerCountAll
        customerCountMerchant : customerCountMerchant
        staffCountAll         : staffCountAll
        staffCountMerchant    : staffCountMerchant
        deliveryProductCount  : 0
        deliveryCount         : 0
        saleCount             : 0
        saleCountDay          : 0
        saleCountMonth        : 0
        returnCount           : 0
        returnCountDay        : 0
        returnCountMonth      : 0
        revenue               : 0
        revenueDay            : 0
        revenueMonth          : 0


