Sky.template.extends Template.iCooldown,
  ui:
    iCooldown: ".iCooldown"

  rendered: ->
    options = @data.options
    $iCooldown = $(@ui.iCooldown)
    $iCooldown.knob()
    timeHook = new Date

    interval = setInterval ->
      console.log 'animating...'
      startAt = options.startAt ? new Date
      buget = (options.buget ? 0) * 60000

      pastedPercentage = ((new Date - startAt) / buget) * 100
      $iCooldown.val(pastedPercentage).trigger('change')
      clearInterval(interval) if(pastedPercentage > 100)
    , 50