pad =(number) -> if number < 10 then '0' + number else number

Sky.template.extends Template.taskDetailThumbnail,
  colorClass: ->
    switch @status
      when 0 then 'asbestos'
      when 1
        if @lateDuration then 'pumpkin' else 'lime'
      when 2 then 'purple'
      when 3
        if @lateDuration then 'carrot' else 'peter-river'
  priorityAlias: ->
    priority = _.findWhere(Sky.system.priorityTasks, {_id: @priority})
    priority.display
  creatorAlias: -> Sky.helpers.shortName(Schema.userProfiles.findOne({user: @creator})?.fullName if @creator)
  ownerAlias: -> Sky.helpers.shortName(Schema.userProfiles.findOne({user: @owner})?.fullName if @owner)
  formatedBuget: -> "#{pad(Math.floor(@duration/60))}:#{pad(@duration%60)}"

  hideEdit:-> return "display: none" unless @status is Sky.system.taskStatuses.wait.key
  hideSkip:-> return "display: none" unless @status is Sky.system.taskStatuses.wait.key
  hideWait:-> return "display: none" unless @status is Sky.system.taskStatuses.skip.key
  hideSelect:-> return "display: none" unless @status is Sky.system.taskStatuses.wait.key and @duration > 0
  hideFrozen:-> return "display: none" unless @status is Sky.system.taskStatuses.working.key or @status is Sky.system.taskStatuses.rejected.key
  hideRejected:-> return "display: none" unless @status is Sky.system.taskStatuses.confirming.key
  hideWorking:-> return "display: none"  unless @status is Sky.system.taskStatuses.selected.key or @status is Sky.system.taskStatuses.frozen.key or @status is Sky.system.taskStatuses.rejected.key or @status is Sky.system.taskStatuses.remaking.key
  hideConfirming:-> return "display: none" unless @status is Sky.system.taskStatuses.working.key
  hideDone:-> return "display: none" unless @status is Sky.system.taskStatuses.confirming.key
  hideRemaking:-> return "display: none" unless @status is Sky.system.taskStatuses.done.key




  events:
    'dblclick .fa.fa-tasks': (event, template)->
      #----Skip to Wait----
      if @status is Sky.system.taskStatuses.skip.key
        Schema.tasks.update(@_id, $set:{status: Sky.system.taskStatuses.wait.key})
    'dblclick .fa.fa-times': (event, template)->
      #----Wait to Skip----
      if @status is Sky.system.taskStatuses.wait.key
        Schema.tasks.update(@_id, $set:{status: Sky.system.taskStatuses.skip.key})
    'dblclick .fa.fa-thumb-tack': (event, template)->
      #----Wait to Selected----
      if @status is Sky.system.taskStatuses.wait.key and @duration > 0
        Schema.tasks.update(
          @_id
        ,
          $set:
            owner       : Meteor.userId()
            selectDate  : new Date
            status      : Sky.system.taskStatuses.selected.key
        ,
          $inc:{totalDuration: @duration}
        )
    'dblclick .fa.fa-pause': (event, template)->
      #----Selected to Frozen---
      if @status is Sky.system.taskStatuses.selected.key and @owner is Meteor.userId()
        Schema.tasks.update(@_id, $set:{starDate: new Date, status: Sky.system.taskStatuses.frozen.key})
      #----Working to Frozen----
      if @status is Sky.system.taskStatuses.working.key and @owner is Meteor.userId()
        Schema.tasks.update(@_id, $set:{finishDate: new Date, status: Sky.system.taskStatuses.frozen.key})
      #----Rejected to Frozen----
      if @status is Sky.system.taskStatuses.rejected.key and @owner is Meteor.userId()
        Schema.tasks.update(@_id, $set:{finishDate: new Date, status: Sky.system.taskStatuses.frozen.key})
    'dblclick .fa.fa-play': (event, template)->
      #----Selected to Working---
      if @status is Sky.system.taskStatuses.selected.key and @owner is Meteor.userId()
        Schema.tasks.update(@_id, $set:{starDate: new Date, status: Sky.system.taskStatuses.working.key})
      #----Frozen to Working----
      if @status is Sky.system.taskStatuses.frozen.key and @owner is Meteor.userId()
        Schema.tasks.update(@_id, $set:{starDate: new Date, status: Sky.system.taskStatuses.working.key})
      #----Rejected to Working----
      if @status is Sky.system.taskStatuses.rejected.key and @owner is Meteor.userId()
        Schema.tasks.update(@_id, $set:{starDate: new Date, status: Sky.system.taskStatuses.working.key})
      #----Remaking to Working----
      if @status is Sky.system.taskStatuses.remaking.key and @owner is Meteor.userId()
        Schema.tasks.update(@_id, $set:{starDate : new Date, status: Sky.system.taskStatuses.working.key})
    'dblclick .fa.fa-question-circle': (event, template)->
      #----Working to Confirming----
      if @status is Sky.system.taskStatuses.working.key and @owner is Meteor.userId()
        Schema.tasks.update(@_id, $set:{finishDate: new Date, status: Sky.system.taskStatuses.confirming.key})
    'dblclick .fa.fa-exclamation-triangle': (event, template)->
      #----Confirming to Rejected----
      if @status is Sky.system.taskStatuses.confirming.key and @creator is Meteor.userId()
        Schema.tasks.update(@_id, $set:{status: Sky.system.taskStatuses.rejected.key})
    'dblclick .fa.fa-trophy': (event, template)->
      #----Confirming to Done----
      if @status is Sky.system.taskStatuses.confirming.key and @creator is Meteor.userId()
        Schema.tasks.update(@_id, $set:{status: Sky.system.taskStatuses.done.key})
    'dblclick .fa.fa-retweet': (event, template)->
      #----Done to Remaking----
      if @status is Sky.system.taskStatuses.done.key and @owner is Meteor.userId()
        Schema.tasks.update(@_id, $set:{status: Sky.system.taskStatuses.remaking.key}, $inc:{remake: 1})








  cooldownOptions: -> {
    context: @
    startAt: @startDate ? new Date(new Date - 0 * 60000)
    buget: @duration ? 1
    width: 74
    others:
      thickness: 0.1
      bgColor: "#fff"
      fgColor: "#8cbf26"
      angleOffset: 28
      angleArc: 304
    }