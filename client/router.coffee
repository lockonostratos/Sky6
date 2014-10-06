animateUsing = (selector, animationType) ->
  $element = $(selector)
#  $element.removeAttr('style')
  $element.removeClass()
  .addClass("animated #{animationType}")
  .one('webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', -> $element.removeClass())

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
      @onBeforeAction = -> AccountsEntry.signInRequired(this); Sky.helpers.reArrangeLayout()
    @onBeforeAction = onBeforeAction if onBeforeAction

  onAfterAction: ->
    $("body").removeClass() if @path isnt '/'
    animateUsing("#right-side", "bounceInUp")
    animateUsing("#container", "bounceInDown")

Router.map ->
  @route 'metroHome', new skyRouter('/', false, ->
    AccountsEntry.signInRequired(this)
    $("body").addClass("dark")
  )
  @route 'home', new skyRouter('home')

  @route route, new skyRouter(route) for route of Sky.menu


  @route 'warehouse', new skyRouter('warehouse')
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
