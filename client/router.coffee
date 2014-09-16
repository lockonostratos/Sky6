Router.configure
  layoutTemplate: 'layout'

#  path: "/posts/:_id"
#  data: ->
#    Posts.findOne @params._id
#
#  waitOn: postsSub
#  loading: "loadingTemplate"
#  notFound: "notFoundTemplate"
#  onAfterRun: ->
#    $("#newPage").addClass "slide.in"
#    $("#newPage").addClass "visible"
#    return
#
#  onAfterRerun: ->
#    $("#newPage").addClass "visible"
#    return

class @skyRouter
  constructor: (@path, authRequired = true) ->
    if authRequired
      @onBeforeAction = -> AccountsEntry.signInRequired(this)

  onAfterAction: ->
    console.log 'this is after Router action!'
    $('#right-side').removeClass()
     .addClass("animated fadeIn")
     .one('webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', -> $(@).removeClass())

Router.map ->
  @route 'metroHome', new skyRouter('/')
  @route 'home', new skyRouter('home')
  @route 'warehouse', new skyRouter('warehouse')
  @route 'sales', new skyRouter('sales')
  @route 'import', new skyRouter('import')
  @route 'delivery', new skyRouter('delivery')
  @route 'returns', new skyRouter('returns')
  @route 'inventory', new skyRouter('inventory')
  @route 'report', new skyRouter('report')
  @route 'roleManager', new skyRouter('roleManager')