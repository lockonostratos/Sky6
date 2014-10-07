pad =(number) -> if number < 10 then '0' + number else number

Sky.template.extends Template.taskDetailThumbnail,
  colorClass: ->
    switch @status
      when 'wait' then 'asbestos'
      when 'selected' then 'amethyst'
      when 'working' then 'teal'
      when 'done' then 'lime'
      when 'confirming' then 'carrot'
      when 'frozen' then 'blue'
      when 'rejected' then 'pumpkin'

  priorityAlias: ->
    priority = _.findWhere(Sky.system.priorityTasks, {_id: @priority})
    priority.display
  creatorAlias: -> Sky.helpers.shortName(Schema.userProfiles.findOne({user: @creator})?.fullName if @creator)
  ownerAlias: -> Sky.helpers.shortName(Schema.userProfiles.findOne({user: @owner})?.fullName if @owner)
  formatedBuget: -> "#{pad(Math.floor(@duration/60))}:#{pad(@duration%60)}"

#  hideWait:-> return "display: none" unless @status is Sky.system.taskStatuses.skip.key
  hideEdit:-> return "display: none" unless @status is Sky.system.taskStatuses.wait.key
  hideSelect:-> return "display: none" unless @status is Sky.system.taskStatuses.wait.key and @duration > 0
  hideFrozen:-> return "display: none" unless @status is Sky.system.taskStatuses.working.key or @status is Sky.system.taskStatuses.rejected.key
  hideRejected:-> return "display: none" unless @status is Sky.system.taskStatuses.confirming.key
  hideRemaking:-> return "display: none" unless @status is Sky.system.taskStatuses.done.key
  hideWorking:-> return "display: none"  unless @status is Sky.system.taskStatuses.selected.key or @status is Sky.system.taskStatuses.frozen.key or @status is Sky.system.taskStatuses.rejected.key or @status is Sky.system.taskStatuses.remaking.key
  hideConfirming:-> return "display: none" unless @status is Sky.system.taskStatuses.working.key
  hideDone:-> return "display: none" unless @status is Sky.system.taskStatuses.confirming.key
  hideDeleted:-> return "display: none" unless @deleted is false

  events:
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
    'dblclick .fa.fa-trash': (event, template)->
      #----deleted to unDeleted----
      if @deleted is false then Schema.tasks.update(@_id, $set:{deleted: true})


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