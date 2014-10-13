Schema.add 'userProfiles', class UserProfile
  @update: (options) ->
    userProfile = @schema.findOne({user: Meteor.userId()})
    @schema.update(userProfile._id, {$set: options})

  set: (options) -> @schema.update(@id, {$set: options})

  @newDefault: (merchantId, warehouseId, userId, systemVersion, fullName) ->
    option=
      user            : userId
      isRoot          : true
      fullName        : fullName
      parentMerchant  : merchantId
      currentMerchant : merchantId
      currentWarehouse: warehouseId
      systemVersion   : systemVersion
    console.log option
    option


  addBranch: (option)->
    option.parent   = @data.parentMerchant
    option.creator = @data.user
    Schema.merchants.insert option, (error, merchantId)->
      if error then console.log error
      else
        Schema.warehouses.insert Warehouse.newDefault(merchantId), (error, result)->
          if error then console.log error
        Schema.metroSummaries.insert MetroSummary.newByMerchant(merchantId), (error, result)->
          if error then console.log error
        MetroSummary.updateMetroSummaryBy(['branch'])


  removeBranch: (brachId)->
    branch = Schema.merchants.findOne({_id: brachId, parent: {$exists: true}})
    if branch
      metroSummary = Schema.metroSummaries.findOne(merchant: branch._id)
      if !metroSummary || metroSummary.productCount == metroSummary.customerCount == metroSummary.staffCount == 0
        for item in Schema.warehouses.find({merchant: branch._id}).fetch()
          Schema.warehouses.remove item._id
        Schema.metroSummaries.remove metroSummary._id if metroSummary
        Schema.merchants.remove branch._id
        MetroSummary.updateMetroSummaryBy(['branch'])
