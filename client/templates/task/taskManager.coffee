taskDefaultSort = {sort: {'version.updateAt': -1, 'version.createdAt': -1}}

formatPriorityTaskSearch  = (item) -> "#{item.display}" if item
formatViewTaskSearch     = (item) -> "#{item.display}" if item
formatOwnerTaskSearch     = (item) -> "#{item.fullName}" if item

checkAllowCreate = (context) ->
  description = context.ui.$description.val()
  if description.length > 0
    Session.set('allowCreateNewTask', true)
  else
    Session.set('allowCreateNewTask', false)

calculateMinuteToTime = (item)->
  hour = Math.floor(item/60); minute = (item/60 - hour)*60
  if hour > 12 then time = "#{hour}:#{minute} PM" else time = "#{hour}:#{minute} AM"
  time

createTask = (context) ->
  description = context.ui.$description.val()
  group = context.ui.$group.val()
  option =
    creator     : Meteor.userId()
    description : description
    priority    : Session.get('currentPriorityTask')
    duration    : Session.get('currentDurationTask')
    status      : Sky.system.taskStatuses.wait.key
    remake      : 0
    lateDuration: false
    deleted     : false

  if group.length > 0 then option.group = group
  if Session.get('currentOwnerTask') then option.owner = Session.get('currentOwnerTask')

  task = Schema.tasks.insert option
  Schema.tasks.update(task, {})
  resetForm(context)
  Session.set('allowCreateNewTask', false)
  Session.set('currentOwnerTask')

updateTask = ->
  option =
    owner       : Session.get('currentOwnerTask')
    group       : Session.get('currentGroupTask')
    description : Session.get('currentDescriptionTask')
    priority    : Session.get('currentPriorityTask')
    duration    : Session.get('currentDurationTask')
  Schema.tasks.update  Session.get('currentTaskDetail')._id, $set: option, (error, result) -> console.log error if error

resetTask = (context) ->
  Session.set('currentTaskDetail')
  Session.set('currentPriorityTask')
  Session.set('currentDurationTask')
  Session.set('currentOwnerTask')
  Session.set('currentDescriptionTask')
  Session.set('currentGroupTask')
  $("[name=duration]").timepicker('setTime', '00:00')
  context.ui.$duration.timepicker('setTime', '00:00 AM') if context

selectUpdateTask = (item, context) ->
  if item.status is Sky.system.taskStatuses.wait.key
    Session.set('currentTaskDetail', item)
    Session.set('currentPriorityTask', item.priority)
    Session.set('currentDurationTask', item.duration)
    Session.set('currentOwnerTask', item.owner)
    if item.description then Session.set('currentDescriptionTask', item.description) else Session.set('currentDescriptionTask')
    if item.group then Session.set('currentGroupTask', item.group) else Session.set('currentGroupTask')
    context.ui.$duration.timepicker('setTime', calculateMinuteToTime(item.duration))
  else
    if Session.get('currentTaskDetail') then resetTask(context)

resetForm = (context) ->
  $(item).val('') for item in context.findAll("[name]")

calculateDuration = (time) -> time.hours*60 + time.minutes

runInitTaskTracker = (context) ->
  return if Sky.global.taskTracker
  Sky.global.taskTracker = Tracker.autorun ->
    Session.set('ownerList', Schema.userProfiles.find({}).fetch())
    if Session.get('statusFilter') && Session.get('userCreatorFilter') && Session.get('userOwnerFilter')
      userCreatorFilter = if Session.get('userCreatorFilter') is "one" then {creator: Meteor.userId()} else {}
      userOwnerFilter = if Session.get('userOwnerFilter') is "one" then {owner: Meteor.userId()} else {}
      deletedFilter = if Session.get('statusFilter') is "deleted" then {deleted: true} else {deleted: false}
      if Session.get('statusFilter') is "all" || Session.get('statusFilter') is "deleted"
        statusFilter = {}
      else
        statusFilter = {status: {$in : Session.get('statusFilter').split(' ')}}
      Session.set 'filteredTasks', Schema.tasks.find({$and:[statusFilter, userCreatorFilter, userOwnerFilter, deletedFilter]},taskDefaultSort).fetch()

Sky.appTemplate.extends Template.taskManager,
  activeStatus: (status)-> return 'active' if Session.get('statusFilter') is status
  activeUserCreator: (user)-> return 'active' if Session.get('userCreatorFilter') is user
  activeUserOwner: (user)-> return 'active' if Session.get('userOwnerFilter') is user
  allowCreate: -> if Session.get('allowCreateNewTask') then 'btn-success' else 'btn-default disabled'
  description : -> if Session.get('currentDescriptionTask') then Session.get('currentDescriptionTask') else ''
  group: -> if Session.get('currentGroupTask') then Session.get('currentGroupTask') else ''
  hideCreate: -> return "display: none" if Session.get('currentTaskDetail')
  hideUpdate: -> return "display: none" unless Session.get('currentTaskDetail')
  currentSystemVersion: -> Schema.systems.findOne()?.version ? ''
  priorityTaskSelectOption:
    query: (query) -> query.callback
      results: Sky.system.priorityTasks
    initSelection: (element, callback) -> callback _.findWhere(Sky.system.priorityTasks, {_id: Session.get('currentPriorityTask')})
    formatSelection: formatPriorityTaskSearch
    formatResult: formatPriorityTaskSearch
    placeholder: 'CHỌN'
    minimumResultsForSearch: -1
    changeAction: (e) ->
      Session.set('currentPriorityTask', e.added._id )
    reactiveValueGetter: ->_.findWhere(Sky.system.priorityTasks, {_id: Session.get('currentPriorityTask')})

  ownerTaskSelectOption:
    query: (query) -> query.callback
      results: Session.get('ownerList')
    initSelection: (element, callback) -> callback (
      if Session.get('currentOwnerTask')
        _.findWhere(Session.get('ownerList'), {user: Session.get('currentOwnerTask')})
      else
        'skyReset')
    formatSelection: formatOwnerTaskSearch
    formatResult: formatOwnerTaskSearch
    placeholder: 'CHỌN NGƯỜI THỰC HIỆN'
    minimumResultsForSearch: -1
    others:
      allowClear: true
    changeAction: (e) ->
      Session.set('currentOwnerTask') if e.removed
      Session.set('currentOwnerTask', e.added.user) if e.added
    reactiveValueGetter: ->
      if Session.get('currentOwnerTask')
        _.findWhere(Session.get('ownerList'), {user: Session.get('currentOwnerTask')})
      else
        'skyReset'

  taskDetailOptions:
    itemTemplate: (context) ->
      if context.status == 0 then 'taskDetailThumbnail' else 'taskDetailThumbnail'
    reactiveSourceGetter: -> Session.get('filteredTasks')
    wrapperClasses: 'detail-grid row'

  created: ->
    Session.setDefault('allowCreateNewTask', false)
    Session.setDefault('userCreatorFilter', 'all')
    Session.setDefault('userOwnerFilter', 'all')
    Session.setDefault('statusFilter', 'wait')
    Session.setDefault('currentPriorityTask', 1)
    Session.setDefault('currentDurationTask', 0)


  events:
    "click [data-status]": (event, template) ->
      $element = $(event.currentTarget)
      Session.set 'statusFilter', $element.attr("data-status")
    "click [data-user-creator]": (event, template) ->
      $element = $(event.currentTarget)
      Session.set 'userCreatorFilter', $element.attr("data-user-creator")
    "click [data-user-owner]": (event, template) ->
      $element = $(event.currentTarget)
      Session.set 'userOwnerFilter', $element.attr("data-user-owner")

    "input input": (event, template) -> checkAllowCreate(template)
    "click #createTask": (event, template) -> createTask(template)

    "click #resetTask": (event, template) -> resetTask(template)
    "click #updateTask": (event, template) -> updateTask(template); resetTask()

    'blur .group': (event, template)-> Session.set('currentGroupTask', template.ui.$group.val())
    'blur .description': (event, template)-> Session.set('currentDescriptionTask', template.ui.$description.val())

    "click .taskDetail .fa.fa-unlock": (event, template) -> resetTask(template)
    "click .taskDetail .fa.fa-pencil-square-o": (event, template) -> selectUpdateTask(@, template)

  rendered: ->
    runInitTaskTracker()
    self = @
    @ui.$duration.timepicker
      showMeridian: false
      defaultTime: '00:00'

    @ui.$duration.timepicker().on('changeTime.timepicker', (e)->
      Session.set('currentDurationTask', calculateDuration(e.time))
    )


