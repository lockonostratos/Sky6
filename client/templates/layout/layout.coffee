_.extend Template.layout,
  collapse: -> console.log Session.get('collapse'); Session.get('collapse') ? 'collapsed'
  events:
    'click .collapse-toggle': -> application.toggleCollapse()