Sky.template.extends Template.taskDetailThumbnail,
  colorClass: ->
    switch @status
      when 0 then 'asbestos'
      when 1
        if @lateDuration then 'pumpkin' else 'lime'
      when 2 then 'purple'
      when 3
        if @lateDuration then 'carrot' else 'peter-river'
  status: ->
    return "chưa xử lý" if @status is 0
    return "đang xử lý" if @status is 1
    return "đã xử lý"   if @status is 2
    return "xác nhận ok" if @status is 3
  priorityDisplay: ->
    priority = _.findWhere(Sky.system.priorityTasks, {_id: @priority})
    priority.display
  creatorName: -> Sky.helpers.shortName(Schema.userProfiles.findOne({user: @creator})?.fullName if @creator)
  ownerName: -> Sky.helpers.shortName(Schema.userProfiles.findOne({user: @owner})?.fullName if @owner)
  hideIconEdit:-> return "display: none" unless @status is 0 and Session.get('viewTask') == 2
  hideIconUnlock:-> return "display: none" unless @status is 0 and @duration > 0
  hideIconLock:-> return "display: none" unless @status is 1 and @owner == Meteor.userId() and (Session.get('viewTask') == 4 || Session.get('viewTask') == 5)
  hideIconCheck:-> return "display: none" unless @status is 2 and @creator == Meteor.userId() and (Session.get('viewTask') == 3 || Session.get('viewTask') == 5)

  events:
    'dblclick .fa.fa-unlock': (event, template)->
      if @status == 0 and @duration > 0
        Schema.tasks.update(@_id, $set:{
          owner: Meteor.userId()
          starDate: new Date
          status: 1})
    'dblclick .fa.fa-lock': (event, template)->
      if @status == 1 and @owner == Meteor.userId()
        Schema.tasks.update(@_id, $set:{
          finishDate   : new Date
          status       : 2})
    'dblclick .fa.fa-reply': (event, template)->
      if @status == 2 and @creator == Meteor.userId()
        Schema.tasks.update(@_id, $set:{status: 1})
    'dblclick .fa.fa-check': (event, template)->
      if @status == 2 and @creator == Meteor.userId()
        Schema.tasks.update(@_id, $set:{finishDate: new Date, status: 3})

