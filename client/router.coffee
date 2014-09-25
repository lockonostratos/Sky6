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
  constructor: (@path, authRequired = true, onBeforeAction = null) ->
    if authRequired
      @onBeforeAction = -> AccountsEntry.signInRequired(this)
    @onBeforeAction = onBeforeAction if onBeforeAction

  onAfterAction: ->
#    console.log 'this is after Router action!'
    $("body").removeClass() if @path isnt '/'
    $('#right-side').removeAttr('style')
    $('#right-side').removeClass()
     .addClass("animated fadeIn")
     .one('webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', -> $(@).removeClass())

Router.map ->
  @route 'metroHome', new skyRouter('/', false, ->
    AccountsEntry.signInRequired(this)
    $("body").addClass("dark")
  )
  @route 'home', new skyRouter('home')
  @route 'warehouse', new skyRouter('warehouse')
  @route 'sales', new skyRouter('sales')
  @route 'billManager', new skyRouter('billManager')
  @route 'import', new skyRouter('import')
  @route 'delivery', new skyRouter('delivery')
  @route 'returns', new skyRouter('returns')
  @route 'inventory', new skyRouter('inventory')
  @route 'report', new skyRouter('report')
  @route 'roleManager', new skyRouter('roleManager')
  @route 'staffManager', new skyRouter('staffManager')
  @route 'customerManager', new skyRouter('customerManager')
  @route 'branchManager', new skyRouter('branchManager')