Schema.add 'userProfiles', class UserProfile
  @update: (options) ->
    userProfile = @schema.findOne({user: Meteor.userId()})
    @schema.update(userProfile._id, {$set: options})

  set: (options) -> @schema.update(@id, {$set: options})

  @newDefault: (userId, companyName, companyPhone) ->
    option=
      user            : userId
      isRoot          : true
      merchantRegistered: false
      companyName     : companyName
      companyPhone    : companyPhone
      systemVersion   : Schema.systems.findOne().version
    console.log option
    option

  updateNewMerchant: (companyName, companyPhone, merchantName, warehouseName)->
    merchant = Schema.merchants.insert { name: merchantName , creator: @data.user },
      (error, result)-> console.log error if error

    warehouseOption =
      merchantId: merchant
      parentMerchantId: merchant
      creator: @data.user
      name: warehouseName
    warehouse = Schema.warehouses.insert Warehouse.newDefault(warehouseOption),
      (error, result)-> console.log error if error

    Schema.userProfiles.update @id, $set:{
      merchantRegistered: true
      companyName: companyName
      companyPhone: companyPhone
      parentMerchant: merchant
      currentMerchant: merchant
      currentWarehouse: warehouse}, (error, result)-> console.log error if error

    Schema.metroSummaries.insert MetroSummary.newByMerchant(merchant),
      (error, result)-> console.log error if error


  addBranch: (option)->
    option.parent   = @data.parentMerchant
    option.creator = @data.user
    Schema.merchants.insert option, (error, merchantId)->
      if error then console.log error
      else
        Schema.warehouses.insert Warehouse.newDefault({merchantId: merchantId}), (error, result)->
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
