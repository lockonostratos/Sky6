Sky.template.extends Template.iCooldown,
  ui:
    iCooldown: ".iCooldown"

  rendered: ->
    options = @data.options
    radius = ((options.width ? 200) / 2) ? 100
    minArcLength = Math.PI * 2 * radius * (1/360)
    maxStep = minArcLength * 1000
    startAt = options.startAt ? new Date
    buget = (options.buget ? 0) * 60000
    timeHook = new Date
    animationSpeed = buget / maxStep
    animationSpeed = 16 if animationSpeed < 16

    $iCooldown = $(@ui.iCooldown)

    cooldownConfigures =
      max: maxStep
      readOnly: true

    cooldownConfigures.width = options.width if options.width

    _.extend(cooldownConfigures, options.others) if options.others

    $iCooldown.knob cooldownConfigures

    @data.interval = setInterval =>
      pastedSteps = ((new Date - startAt) / buget) * maxStep
      $iCooldown.val(pastedSteps).trigger('change')
      clearInterval(@data.interval) if(pastedSteps > maxStep)
    , animationSpeed

  destroyed: ->
    clearInterval(@data.interval)