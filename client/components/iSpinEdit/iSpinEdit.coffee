registerSpinEdit = ($element, context) ->
  options = {}
  options.initVal = context.data.options.reactiveValue()
  options.min = context.data.options.reactiveMin()
  options.max = context.data.options.reactiveMax()
  options.step = context.data.options.reactiveStep()
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
    if context.data.options.reactiveSetter && isValueValid(context, parsedValue)
      context.data.options.reactiveSetter(Number(parsedValue))

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
