Schema.add 'userProfiles', class UserProfile
  @update: (options) ->
    userProfile = @schema.findOne({user: Meteor.userId()})
    @schema.update(userProfile._id, {$set: options})

  set: (options) -> @schema.update(@id, {$set: options})

  @newDefault: (userId, companyName, companyPhone) ->
    option=
      user              : userId
      isRoot            : true
      merchantRegistered: false
      packageClass      : 'free'
      companyName       : companyName
      companyPhone      : companyPhone
      systemVersion     : Schema.systems.findOne().version
    console.log option
    option

  updateNewMerchant: (optionMerchant, optionPackage)->
    merchant = Schema.merchants.insert { name: optionMerchant.merchantName , creator: @data.user },
      (error, result)-> console.log error if error
    console.log optionPackage
    optionPackage.merchant            = merchant
    optionPackage.user                = @data.user
    optionPackage.packageClassActive  = false
    date = new Date
    optionPackage.trialEndDate = new Date(date.getTime() + 86400000 * 14)

    if optionPackage.packageClass is 'free'
      optionPackage.extendAccountLimit    = 0
      optionPackage.extendBranchLimit     = 0
      optionPackage.extendWarehouseLimit  = 0
      optionPackage.totalPrice = 0
    else
      extendAccountTotalPrice    = optionPackage.extendAccountPrice * optionPackage.extendAccountLimit
      extendBranchTotalPrice    = optionPackage.extendBranchPrice * optionPackage.extendBranchLimit
      extendWarehouseTotalPrice  = optionPackage.extendWarehousePrice * optionPackage.extendWarehouseLimit
      optionPackage.totalPrice = extendAccountTotalPrice + extendBranchTotalPrice + extendWarehouseTotalPrice + optionPackage.price

    console.log optionPackage
    Schema.merchantPackages.insert optionPackage

    warehouseOption =
      merchantId: merchant
      parentMerchantId: merchant
      creator: @data.user
      name: optionMerchant.warehouseName
    warehouse = Schema.warehouses.insert Warehouse.newDefault(warehouseOption),
      (error, result)-> console.log error if error

    Schema.userProfiles.update @id, $set:{
      merchantRegistered: true
      companyName: optionMerchant.companyName
      companyPhone: optionMerchant.companyPhone
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
