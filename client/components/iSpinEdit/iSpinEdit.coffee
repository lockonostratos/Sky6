registerSpinEdit = ($element, context) ->
  options = {}
  parentContext = context.data.options.parentContext
  options.initVal = context.data.options.reactiveValue(parentContext)
  options.min = context.data.options.reactiveMin(parentContext)
  options.max = context.data.options.reactiveMax(parentContext)
  options.step = context.data.options.reactiveStep(parentContext)
  _.extend(options, context.data.options.others) if context.data.options.others

  $element.TouchSpin(options)

startTrackingOptions = ($element, context) ->
  context.optionsTracker = Tracker.autorun ->
    $element.trigger "touchspin.updatesettings",
      max: context.data.options.reactiveMax()
      min: context.data.options.reactiveMin()
      step: context.data.options.reactiveStep()
      initVal: context.data.options.reactiveValue()

stopTrackingOptions = (context) -> context.optionsTracker.stop()

startTrackingValue = ($element, context) ->
  $element.on 'change', (e) ->
    parsedValue = accounting.parse(e.target.value)
    parentContext = context.data.options.parentContext
    if context.data.options.reactiveSetter && isValueValid(context, parsedValue)
      context.data.options.reactiveSetter(Number(parsedValue), parentContext)

isValueValid = (context, value) ->
    value >= context.data.options.reactiveMin() &&
    value <= context.data.options.reactiveMax()

Sky.template.extends Template.iSpinEdit,
  reactiveValue: -> UI._templateInstance().data.options.reactiveValue()
  ui:
    component: "input"

  rendered: ->
    $component = $(@ui.component)
    registerSpinEdit($component, @)
    startTrackingOptions($component, @)
    startTrackingValue($component, @)

  destroyed: -> stopTrackingOptions(@)
