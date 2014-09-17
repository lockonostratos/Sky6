Sky.template.extends Template.sidebar,
  leftCollapseIcon: ->
    if Session.get('collapse') is 'collapsed'
      'fa fa-angle-double-right'
    else
      'fa fa-angle-double-left'
  testIcon: 'asdsdsad'
