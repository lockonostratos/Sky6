_.extend Template.layout,
  collapse: -> Session.get('collapse') ? 'collapsed'

  rendered: ->
    $(window).resize -> Sky.helpers.reArrangeLayout()

  events:
    "click .collapse-toggle": -> application.toggleCollapse()