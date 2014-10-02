Sky.appTemplate.extends Template.home,
  cooldownOptions:
    startAt: new Date(new Date - 0 * 60000)
    buget: 0.5
    others:
      fgColor: "#7caa22"

  rendered: ->
    console.log "Home is showing up, awesome!"

  events:
    'click input': -> console.log 'Fuck YOU!'
    'click h1': -> console.log 'text clicked'