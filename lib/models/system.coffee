Schema.add 'systems', class System
  @upgradeVersion: (step = 0.1) ->
    currentVersion = Schema.systems.findOne()
    subversion = currentVersion.version.substring(2)
    version = currentVersion.version.substring(0,1)

    nextSubversion = Math.round((Number(subversion) + step)*10)/10
    if nextSubversion > 10
      nextSubversion = Math.round((nextSubversion - 10)*10)/10
      version++

    nextVersion = "#{version}.#{nextSubversion}"

    finishAfterCurrentVersion = {'version.updateAt': {$gt: currentVersion.updateAt}}
    doneTasks = { status: Sky.system.taskStatuses.done.key }
    updates = Schema.tasks.find({$and: [doneTasks, finishAfterCurrentVersion]}).fetch()

    if updates.length is 0
      console.log "Upgrading failed, there is no change from previous update!"
      return

    for update in updates
      Schema.migrations.insert
        systemVersion: nextVersion
        description: update.description
        creator: update.creator
        owner: update.owner
        group: [update.group]

    Schema.systems.update(currentVersion._id, {$set: {version: nextVersion}})
    console.log "System successfully upgraded to version #{nextVersion}"
    return

  @checkUpdates: ->
    currentVersion = Schema.systems.findOne()
    finishAfterCurrentVersion = {'version.updateAt': {$gt: currentVersion.updateAt}}
    doneTasks = { status: Sky.system.taskStatuses.done.key }
    updates = Schema.tasks.find({$and: [doneTasks, finishAfterCurrentVersion]}).fetch()
    console.log "There is #{updates.length} updates since previous version:"
    console.log "#{update.group}: #{update.description}" for update in updates
    return

  @createNewMetroSummary: ->
    userProfile = Schema.userProfiles.findOne({user: Meteor.userId()})
    unless metro = Schema.metroSummaries.findOne({merchant: userProfile.currentMerchant})
      metroId = Schema.metroSummaries.insert(MetroSummary.newByMerchant(userProfile.currentMerchant))
    else metroId = metro._id
    MetroSummary.findOne(metroId).updateMetroSummary()

  @registerNewMerchant:(email, password, merchantName = null, fullName = null)->
    Meteor.call "registerMerchant", email, password, (error, result)->
      if error
        console.log error
      else
        user = result
        merchantName = email unless merchantName?.length > 0
        fullName = email unless fullName?.length > 0

        merchant = Schema.merchants.insert { name: merchantName , creator: user }, (error, result)->
          if error
            console.log error

        warehouseOption =
          merchantId: merchant
          parentMerchantId: merchant
          creator: user
        warehouse = Schema.warehouses.insert Warehouse.newDefault(warehouseOption), (error, result)->
          if error
            console.log error
        version = Schema.systems.findOne().version
        Schema.userProfiles.insert UserProfile.newDefault(merchant, warehouse, user, version, fullName), (error, result)->
          if error
            console.log error
        Schema.metroSummaries.insert MetroSummary.newByMerchant(merchant), (error, result)->
          if error
            console.log error


