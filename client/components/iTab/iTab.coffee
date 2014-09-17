destroyTab = (context, instance) ->
  allTabs = Session.get(context.options.source)
  currentSource = _.findWhere(allTabs, {_id: instance._id})
  currentIndex = allTabs.indexOf(currentSource)
  currentLength = allTabs.length

  if currentLength > 1
    context.options.destroyAction(instance)
    nextIndex = if currentIndex == currentLength - 1 then currentIndex - 1 else currentIndex + 1
    Session.set(context.options.currentSource, allTabs[nextIndex])
    context.options.navigateAction(allTabs[nextIndex]) if context.options.navigateAction
  else
    console.log 'cannot delete'; return if instance.brandNew
    context.options.destroyAction(instance)
    newTab = context.options.createAction()
    newTab.brandNew = true
    Session.set(context.options.currentSource, newTab)
    context.options.navigateAction(newTab) if context.options.navigateAction

generateActiveClass = (context, instance) ->
  key = context.data.options.key
  currentSource = Session.get(context.data.options.currentSource)
  if !currentSource || instance[key] isnt currentSource[key] then '' else 'active'

Sky.template.extends Template.iTab,
  sources: -> Session.get(@options.source)
  getCaption: -> @[UI._templateInstance().data.options.caption ? 'caption']
  activeClass: -> generateActiveClass(UI._templateInstance(), @)

  events:
    "click li:not(.new-button):not(.active)": (event, template) ->
      Session.set(template.data.options.currentSource, @)
      template.data.options.navigateAction(@) if template.data.options.navigateAction
    "click li.new-button": (event, template) ->
      Session.set(template.data.options.currentSource, template.data.options.createAction())
    "dblclick span.fa": (event, template) ->
      destroyTab(template.data, @); event.stopPropagation()