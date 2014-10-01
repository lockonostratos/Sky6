Sky.appTemplate.extends Template.home,
  cooldownOptions:
    startAt: new Date(new Date - 2 * 60000)
    buget: 5

  rendered: ->
    console.log "Home is showing up, awesome!"

  events:
    'click input': -> console.log 'Fuck YOU!'
    'click h1': -> console.log 'text clicked'