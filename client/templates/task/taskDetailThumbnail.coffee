pad =(number) -> if number < 10 then '0' + number else number
taskDefaultLifeTime = (7 * 24 * 60)

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
  hideIconEdit:-> return "display: none" unless @status is 0 and Session.get('viewTask') == 2
  hideIconUnlock:-> return "display: none" unless @status is 0 and @duration > 0
  hideIconLock:-> return "display: none" unless @status is 1 and @owner == Meteor.userId() and (Session.get('viewTask') == 4 || Session.get('viewTask') == 5)
  hideIconCheck:-> return "display: none" unless @status is 2 and @creator == Meteor.userId() and (Session.get('viewTask') == 3 || Session.get('viewTask') == 5)
  formatedBuget: -> "#{pad(Math.floor(@duration/60))}:#{pad(@duration%60)}"

  events:
    'dblclick .fa.fa-unlock': (event, template)->
      if @status is Sky.system.taskStatuses.waiting and @duration > 0
        Schema.tasks.update(@_id, $set:{
          owner: Meteor.userId()
          starDate: new Date
          status: Sky.system.taskStatuses.waiting})
    'dblclick .fa.fa-lock': (event, template)->
      if @status is Sky.system.taskStatuses.selected and @owner is Meteor.userId()
        Schema.tasks.update(@_id, $set:{
          finishDate   : new Date
          status       : Sky.system.taskStatuses.selected})
    'dblclick .fa.fa-reply': (event, template)->
      if @status is Sky.system.taskStatuses.rejected and @creator == Meteor.userId()
        Schema.tasks.update(@_id, $set:{status: Sky.system.taskStatuses.rejected})
    'dblclick .fa.fa-check': (event, template)->
      if @status == 5 and @creator == Meteor.userId()
        Schema.tasks.update(@_id, $set:{finishDate: new Date, status: 3})

  cooldownOptions: -> {
    startAt: @startDate ? new Date(new Date - 0 * 60000)
    buget: if Sky.system.taskStatuses.waiting then taskDefaultLifeTime else @duration
    width: 74
    others:
      thickness: 0.1
      bgColor: "#fff"
      fgColor: "#8cbf26"
      angleOffset: 28
      angleArc: 304
  }
