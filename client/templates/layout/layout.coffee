_.extend Template.layout,
  collapse: -> Session.get 'collapse'
  events:
    'click .collapse-toggle': -> application.toggleCollapse()

  rendered: ->