versionUpdatesTracker = ->
  return if Sky.global.versionUpdatesTracker
  Sky.global.versionUpdatesTracker = Tracker.autorun ->
    myCurrentVersion = Session.get('currentProfile')?.systemVersion
    systemCurrentVersion = Schema.systems.findOne()?.version

    if myCurrentVersion < systemCurrentVersion
      updates = Schema.migrations.find({systemVersion: {$gt: myCurrentVersion}}).fetch()
      $.notify(update.description, {autoHide: false, className: 'success'}) for update in updates
      Schema.userProfiles.update(Session.get('currentProfile')._id, {$set: {systemVersion: systemCurrentVersion}})

_.extend Template.merchantLayout,
  collapse: -> Session.get('collapse') ? 'collapsed'

  rendered: ->
    $(window).resize -> Sky.helpers.reArrangeLayout()
    versionUpdatesTracker()
    Sky.helpers.animateUsing("#container", "bounceInDown")

  events:
    "click .collapse-toggle": -> application.toggleCollapse()