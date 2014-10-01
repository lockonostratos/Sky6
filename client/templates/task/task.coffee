formatPriorityTaskSearch  = (item) -> "#{item.display}" if item
formatOwnerTaskSearch     = (item) -> "#{item.fullName}" if item

checkAllowCreate = (context) ->
  description = context.ui.$description.val()

  if description.length > 0 and Session.get('durationTask') > 0
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
    status      : 0
  if group.length > 0 then option.group = group
  if Session.get('ownerTask') then option.owner = Session.get('ownerTask')

  Schema.tasks.insert option
  resetForm(context)
  Session.set('allowCreateNewTask', false)
  Session.set('ownerTask')

resetForm = (context) -> $(item).val('') for item in context.findAll("[name]")
calculateDuration = (time) -> time.hours*60 + time.minutes

runInitTaskTracker = (context) ->
  return if Sky.global.taskTracker
  Sky.global.taskTracker = Tracker.autorun ->
    unless Session.get('priorityTask') then Session.set('priorityTask', 1)
    unless Session.get('durationTask') then Session.set('durationTask', 0)
    Session.set 'taskList', Schema.tasks.find({}).fetch()
    Session.set 'ownerList', Schema.userProfiles.find({}).fetch()

Sky.appTemplate.extends Template.task,
  allowCreate: -> if Session.get('allowCreateNewTask') then 'btn-success' else 'btn-default disabled'

  priorityTaskSelectOption:
    query: (query) -> query.callback
      results: Sky.system.priorityTasks
    initSelection: (element, callback) -> callback _.findWhere(Sky.system.priorityTasks, {_id: Session.get('priorityTask')})
    formatSelection: formatPriorityTaskSearch
    formatResult: formatPriorityTaskSearch
    placeholder: 'CHỌN'
    minimumResultsForSearch: -1
    changeAction: (e) ->  Session.set('priorityTask', e.added._id )
    reactiveValueGetter: ->_.findWhere(Sky.system.priorityTasks, {_id: Session.get('priorityTask')})

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
    placeholder: 'CHỌN'
    minimumResultsForSearch: -1
    others:
      allowClear: true
    changeAction: (e) ->
      Session.set('ownerTask') if e.removed
      Session.set('ownerTask', e.added.user) if e.added


    reactiveValueGetter: ->
      if Session.get('ownerTask')
        _.findWhere(Session.get('ownerList'), {user: Session.get('ownerTask')})
      else
        'skyReset'

  taskDetailOptions:
    itemTemplate: 'taskDetailThumbnail'
    reactiveSourceGetter: -> Session.get('taskList') ? []
    wrapperClasses: 'detail-grid row'

  events:
    "input input": (event, template) -> checkAllowCreate(template)
    "click #createTask": (event, template) -> createTask(template)


  created: -> Session.setDefault('allowCreateNewTask', false)
  rendered: ->
    runInitTaskTracker()
    self = @
    @ui.$duration.timepicker
      showMeridian: false
      defaultTime: '00:00'

    @ui.$duration.timepicker().on('changeTime.timepicker', (e)->
      Session.set('durationTask', calculateDuration(e.time))
      if self.ui.description.value.length > 0 and Session.get('durationTask') > 0
        Session.set('allowCreateNewTask', true)
      else
        Session.set('allowCreateNewTask', false)
    )
