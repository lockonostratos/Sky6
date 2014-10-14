Router.configure
  layoutTemplate: 'merchantLayout'

#  path: "/posts/:_id"
#  data: ->
#    Posts.findOne @params._id
#s
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

Session.setDefault('routeHistory', [])

addRouteToHistory = (routeName) ->
  route  = Sky.menu[routeName]
  return if !route or route.route is 'taskManager'

  routeHistory = Session.get('routeHistory')
  routeHistory.push route if !_.findWhere(routeHistory, {display: route.display})
  routeHistory.splice(0,1) if routeHistory.length > 9
  Session.set('routeHistory', routeHistory)

class @skyRouter
  constructor: (@path, authRequired = true, onBeforeAction = null) ->
    if authRequired
      @onBeforeAction = -> AccountsEntry.signInRequired(this); Sky.helpers.reArrangeLayout()
    @onBeforeAction = onBeforeAction if onBeforeAction

  onAfterAction: ->
#    $("body").removeClass() if @path isnt '/'
    Sky.helpers.animateUsing("#container", "bounceInDown")

    addRouteToHistory @path.substring(1)

Router.map ->
  @route 'home',
    path: '/'
    layoutTemplate: 'homeLayout'

  @route 'metroHome', new skyRouter('/dashboard', false, ->
    AccountsEntry.signInRequired(this)
#    $("body").addClass("dark")
  )
  @route 'warehouse', new skyRouter('warehouse')

  @route route, new skyRouter(route) for route of Sky.menu


#  @route 'sales', new skyRouter('sales') #
#  @route 'billManager', new skyRouter('billManager') #
#  @route 'billExport', new skyRouter('billExport') #
#  @route 'import', new skyRouter('import') #
#  @route 'export', new skyRouter('export')
#  @route 'delivery', new skyRouter('delivery')
#  @route 'returns', new skyRouter('returns')
#  @route 'inventory', new skyRouter('inventory')
#  @route 'inventoryReview', new skyRouter('inventoryReview')
#  @route 'inventoryHistory', new skyRouter('inventoryHistory')
#  @route 'inventoryIssue', new skyRouter('inventoryIssue')
#  @route 'report', new skyRouter('report')
#  @route 'roleManager', new skyRouter('roleManager')
#  @route 'staffManager', new skyRouter('staffManager')
#  @route 'customerManager', new skyRouter('customerManager')
#  @route 'branchManager', new skyRouter('branchManager')
#  @route 'warehouseManager', new skyRouter('warehouseManager')
#  @route 'stockManager', new skyRouter('stockManager')
#  @route 'transactionManager', new skyRouter('transactionManager')
#  @route 'logManager', new skyRouter('logManager')
#  @route 'task', new skyRouter('task')
