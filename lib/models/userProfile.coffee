Schema.add 'userProfiles', class UserProfile
  @update: (options) ->
    userProfile = @schema.findOne({user: Meteor.userId()})
    @schema.update(userProfile._id, {$set: options})

  set: (options) -> @schema.update(@id, {$set: options})

  addBranch: (option)->
    option.parent   = @data.parentMerchant
    option.creator = @data.user
    Schema.merchants.insert option, (error, result) ->
      if error then console.log error
      else
        Schema.metroSummaries.insert MetroSummary.newByMerchant(result)
        Schema.warehouses.insert Warehouse.newDefault(result)

  removeBranch: (brachId)->
    branch = Schema.merchants.findOne({_id: brachId, parent: {$exists: true}})
    if branch
      metroSummary = Schema.metroSummaries.findOne(merchant: branch._id)
      if metroSummary.productCount == metroSummary.customerCountMerchant == metroSummary.staffCountMerchant == 0
        for item in Schema.warehouses.find({merchant: branch._id}).fetch()
          Schema.warehouses.remove item._id
        Schema.metroSummaries.remove metroSummary._id
        Schema.merchants.remove branch._id
