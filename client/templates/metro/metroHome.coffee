_.extend Template.metroHome,
  events:
    "click .app-navigator": (event, template) -> Router.go $(event.currentTarget).attr('data-app')
#  rendered: ->
#    for tile in @findAll('.tile')
#      $tile = $(tile); appUrl = $tile.attr('data-app')
#      if !appUrl then $tile.addClass('locked')