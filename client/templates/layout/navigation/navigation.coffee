_.extend Template.navigation,
  rendered: ->
    $(@find '.collapse-toggle').tooltip
      placement: 'right'
      container: 'body'
      title: 'mở rộng/thu nhỏ'
#  events:
#    'focus .branding input': ->
#      Session.set('collapse', '') if Session.get('collapse') is 'collapsed'
#      console.log Session.get('collapse')