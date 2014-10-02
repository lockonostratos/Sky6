taskDefaultSort = {sort: {'version.createdAt': -1}}

formatPriorityTaskSearch  = (item) -> "#{item.display}" if item
formatViewTaskSearch     = (item) -> "#{item.display}" if item
formatOwnerTaskSearch     = (item) -> "#{item.fullName}" if item

checkAllowCreate = (context) ->
  description = context.ui.$description.val()
  if description.length > 0
    Session.set('allowCreateNewTask', true)
  else
    Session.set('allowCreateNewTask', false)

createTask = (context) ->
  description = context.ui.$description.val()
  group = context.ui.$group.val()

  option =
    creator     : Meteor.userId()
    description : description
    priority    : Session.get('priorityTask')
    duration    : Session.get('durationTask')
    status      : Sky.system.taskStatuses.waiting
    lateDuration: false
  if group.length > 0 then option.group = group
  if Session.get('ownerTask') then option.owner = Session.get('ownerTask')

  Schema.tasks.insert option
  resetForm(context)
  Session.set('allowCreateNewTask', false)
  Session.set('ownerTask')

updateTask = ->
  option =
    owner       : Session.get('ownerTask')
    group       : Session.get('groupTask')
    description : Session.get('descriptionTask')
    priority    : Session.get('priorityTask')
    duration    : Session.get('durationTask')
  Schema.tasks.update  Session.get('taskDetail')._id, $set: option, (error, result) -> console.log error if error

resetTask = (context) ->
  Session.set('taskDetail')
  Session.set('priorityTask')
  Session.set('durationTask')
  Session.set('ownerTask')
  Session.set('descriptionTask')
  Session.set('groupTask')
  $("[name=duration]").timepicker('setTime', '00:00')
  context.ui.$duration.timepicker('setTime', '00:00 AM') if context


selectUpdateTask = (item, context) ->
  if item.status < 1
    Session.set('taskDetail', item)
    Session.set('priorityTask', item.priority)
    Session.set('durationTask', item.duration)
    Session.set('ownerTask', item.owner)
    if item.description then Session.set('descriptionTask', item.description) else Session.set('descriptionTask')
    if item.group then Session.set('groupTask', item.group) else Session.set('groupTask')
    hour = Math.floor(item.duration/60)
    minute = (item.duration/60 - hour)*60
    if hour > 12 then time = "#{hour}:#{minute} PM" else time = "#{hour}:#{minute} AM"
    context.ui.$duration.timepicker('setTime', time)
  else
    if Session.get('taskDetail') then resetTask(context)

resetForm = (context) -> $(item).val('') for item in context.findAll("[name]")

calculateDuration = (time) -> time.hours*60 + time.minutes

runInitTaskTracker = (context) ->
  return if Sky.global.taskTracker
  Sky.global.taskTracker = Tracker.autorun ->
    unless Session.get('priorityTask') then Session.set('priorityTask', 1)
    unless Session.get('durationTask') then Session.set('durationTask', 0)
    unless Session.get('viewTask') then Session.set('viewTask', 2)
    Session.set 'ownerList', Schema.userProfiles.find({}).fetch()
    Session.set 'resetTask', false
    if Session.get('statusFilter') && Session.get('userFilter')
      userFilter = if Session.get('userFilter') is "1" then {owner: Meteor.userId()} else {}
      statusFilter = if Session.get('statusFilter') is "all" then {} else Session.get('statusFilter')

      Session.set 'filteredTasks', Schema.tasks.find({$and: [statusFilter, userFilter]}).fetch()

Sky.appTemplate.extends Template.task,
  allowCreate: -> if Session.get('allowCreateNewTask') then 'btn-success' else 'btn-default disabled'
  description : -> if Session.get('descriptionTask') then Session.get('descriptionTask') else ''
  group: -> if Session.get('groupTask') then Session.get('groupTask') else ''
  hideCreate: -> return "display: none" if Session.get('taskDetail')
  hideUpdate: -> return "display: none" unless Session.get('taskDetail')

  priorityTaskSelectOption:
    query: (query) -> query.callback
      results: Sky.system.priorityTasks
    initSelection: (element, callback) -> callback _.findWhere(Sky.system.priorityTasks, {_id: Session.get('priorityTask')})
    formatSelection: formatPriorityTaskSearch
    formatResult: formatPriorityTaskSearch
    placeholder: 'CHỌN'
    minimumResultsForSearch: -1
    changeAction: (e) ->
      Session.set('priorityTask', e.added._id )
#      Schema.tasks.update Session.get('taskDetail')._id, $set:{priority: e.added._id}  if Session.get('taskDetail')
    reactiveValueGetter: ->_.findWhere(Sky.system.priorityTasks, {_id: Session.get('priorityTask')})

  viewTaskSelectOption:
    query: (query) -> query.callback
      results: Sky.system.viewTasks
    initSelection: (element, callback) -> callback _.findWhere(Sky.system.viewTasks, {_id: Session.get('viewTask')})
    formatSelection: formatViewTaskSearch
    formatResult: formatViewTaskSearch
    placeholder: 'CHỌN CÁCH XEM'
    minimumResultsForSearch: -1
    changeAction: (e) ->
      Session.set('viewTask', e.added._id )
      resetTask()
    reactiveValueGetter: ->_.findWhere(Sky.system.viewTasks, {_id: Session.get('viewTask')})

  ownerTaskSelectOption:
    query: (query) -> query.callback
      results: Session.get('ownerList')
    initSelection: (element, callback) -> callback (
      if Session.get('ownerTask')
        _.findWhere(Session.get('ownerList'), {user: Session.get('ownerTask')})
      else
        'skyReset')
    formatSelection: formatOwnerTaskSearch
    formatResult: formatOwnerTaskSearch
    placeholder: 'CHỌN NGƯỜI THỰC HIỆN'
    minimumResultsForSearch: -1
    others:
      allowClear: true
    changeAction: (e) ->
      Session.set('ownerTask') if e.removed
      Session.set('ownerTask', e.added.user) if e.added
#      if Session.get('taskDetail')
#        if e.added?.user
#          Schema.tasks.update(Session.get('taskDetail')._id, $set:{owner: e.added.user})
#        else
#          Schema.tasks.update(Session.get('taskDetail')._id, $unset:{owner: ''})
    reactiveValueGetter: ->
      if Session.get('ownerTask')
        _.findWhere(Session.get('ownerList'), {user: Session.get('ownerTask')})
      else
        'skyReset'

  taskDetailOptions:
    itemTemplate: (context) ->
      if context.status == 0 then 'taskDetailThumbnail' else 'taskDetailThumbnail'
    reactiveSourceGetter: -> Session.get('filteredTasks') ? []
    wrapperClasses: 'detail-grid row'

  created: ->
    Session.setDefault('allowCreateNewTask', false)
    Session.setDefault('userFilter', 1)
    Session.setDefault('statusFilter', 1)
  events:
    "input input": (event, template) -> checkAllowCreate(template)
    "click #createTask": (event, template) -> createTask(template)
    "click #resetTask": (event, template) -> resetTask(template)
    "click #updateTask": (event, template) -> updateTask(template); resetTask()
    "click .taskDetail .fa.fa-unlock": (event, template) -> resetTask(template)
    "click .taskDetail .fa.fa-pencil-square-o": (event, template) -> selectUpdateTask(@, template)
    "click [data-status]": (event, template) ->
      $element = $(event.currentTarget)
      Session.set 'statusFilter', $element.attr("data-status")
    "click [data-user]": (event, template) ->
      $element = $(event.currentTarget)
      Session.set 'userFilter', $element.attr("data-user")

    'blur .group': (event, template)-> Session.set('groupTask', template.ui.$group.val())
    'blur .description': (event, template)-> Session.set('descriptionTask', template.ui.$description.val())


  rendered: ->
    runInitTaskTracker()
    self = @
    @ui.$duration.timepicker
      showMeridian: false
      defaultTime: '00:00'

    @ui.$duration.timepicker().on('changeTime.timepicker', (e)->
#      if Session.get('taskDetail')
#        Schema.tasks.update Session.get('taskDetail')._id, $set:{duration: calculateDuration(e.time)}
#      else
#        Session.set('durationTask', calculateDuration(e.time))
      Session.set('durationTask', calculateDuration(e.time))

    )


