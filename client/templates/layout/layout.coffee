_.extend Template.layout,
  collapse: -> Session.get('collapse') ? 'collapsed'
  events:
    "click .collapse-toggle": -> application.toggleCollapse()