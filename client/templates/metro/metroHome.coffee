_.extend Template.metroHome,
  events:
    "click .app-navigator": (event, template) -> Router.go $(event.currentTarget).attr('data-app')
#  rendered: ->
#    for tile in @findAll('.tile')
#      $tile = $(tile); app = $tile.attr('data-app')
#      $tile.css('background-color', Sky.menu[app].color[0])