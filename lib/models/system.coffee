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

    if updates.count is 0
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