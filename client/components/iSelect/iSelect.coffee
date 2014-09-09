Sky.template.extends Template.iSelect,
  events:
    "click .select2component": ->
  ui:
    component: ".select2component"
  rendered: ->
    $element = $(@ui.component)
    $element.css('width', @data.width) if @data.width

    registerSelection $element, @
    startTrackingValue $element, @
    makeSlimScroll $element
    setSelection $element, @

  destroyed: ->
    $element = $(@ui.component)

    destroySelection $element, @
    stopTrackingValue @

registerSelection = ($element, context) ->
  console.log 'registering slect2', $element
  selectOptions = {}
  options = context.data.options
  selectOptions.query           = options.query
  selectOptions.formatSelection = options.formatSelection ? options.formatResult
  selectOptions.formatResult    = options.formatResult ? options.formatSelection
  if options.initSelection
    selectOptions.initSelection = (element, callback) -> callback(options.initSelection)

  selectOptions.id              = options.id if options.id
  selectOptions.placeholder     = options.placeholder if options.placeholder

  $element.select2(selectOptions).on 'change', (e) -> options.changeAction()

startTrackingValue = ($element, context) ->
  context.valueTracker = Tracker.autorun -> setSelection($element, context)
  console.log "starting tracking...", context

setSelection = ($element, context) ->
  val = context.data.options.reactiveValueGetter()
  $element.select2('val', val) if val

makeSlimScroll = ($element) -> $element.find('.select2-results').slimScroll({height: '200px'})
destroySelection = ($element, context) ->
  console.log 'destroying slect2', $element
  $element.select2('destroy')
stopTrackingValue = (context) ->
  console.log 'stoping tracking...', context
  context.valueTracker.stop()




#    $component.select2

#    @autoSelectValue = Tracker.autorun ->
#      $component.select2("val", Session.get(self.options.))
