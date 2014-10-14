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

  @createNewUser: (email, fullName, nameMerchant)->
    user = Meteor.users.findOne({'emails.address': email})._id
    unless Schema.userProfiles.findOne(user)
      merchant = Merchant.create { name: nameMerchant, creator: user }
      warehouse = Schema.warehouses.insert Warehouse.newDefault(merchant, merchant, user)
      version = Schema.systems.findOne().version
      Schema.userProfiles.insert UserProfile.newDefault(merchant, warehouse, user, version, fullName)
      Schema.metroSummaries.insert(MetroSummary.newByMerchant(merchant))

  @createNewMetroSummary: ->
    userProfile = Schema.userProfiles.findOne({user: Meteor.userId()})
    unless metro = Schema.metroSummaries.findOne({merchant: userProfile.currentMerchant})
      metroId = Schema.metroSummaries.insert(MetroSummary.newByMerchant(userProfile.currentMerchant))
      MetroSummary.findOne(metroId).updateMetroSummary()


