registerSpinEdit = ($element, context) ->
  options = {}
  options.initVal = context.data.options.reactiveValue()
  options.min = context.data.options.reactiveMin()
  options.max = context.data.options.reactiveMax()
  options.step= context.data.options.reactiveStep()
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
    if context.data.options.reactiveSetter && isValueValid(context, e.target.value)
      context.data.options.reactiveSetter(Number(e.target.value))

isValueValid = (context, value) ->
  numValue = Number(value)
  !isNaN(value) &&
    numValue >= context.data.options.reactiveMin() &&
    numValue <= context.data.options.reactiveMax()

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
