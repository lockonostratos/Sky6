_.extend Template.metroHome,
  userProfile: -> Session.get('currentProfile')?
  metroSummary: -> Session.get('metroSummary') if Session.get('metroSummary')
  events:
    "click .app-navigator:not(.locked)": (event, template) -> Router.go $(event.currentTarget).attr('data-app')
#  rendered: ->
#    for tile in @findAll('.tile')
#      $tile = $(tile); app = $tile.attr('data-app')
#      $tile.css('background-color', Sky.menu[app].color[0])

  unlockRoleManager: -> unless Session.get('metroSummary')?.staffCount ? 0 > 0 then 'locked'
  unlockStaffManager: -> unless Session.get('metroSummary')?.staffCount ? 0 > 0 then 'locked'
  unlockCustomerManager: -> unless Session.get('metroSummary')?.staffCount ? 0 > 0 then 'locked'

  unlockSale: -> unless Session.get('metroSummary')?.importCount ? 0 > 0 then 'locked'
  unlockReturn: -> unless Session.get('metroSummary')?.saleCount ? 0 > 0 then 'locked'
  unlockBillManager: -> unless Session.get('metroSummary')?.saleCount ? 0 > 0 then 'locked'
  unlockTransactionManager: -> unless Session.get('metroSummary')?.importCount ? 0 > 0 then 'locked'
  unlockDelivery: -> unless Session.get('metroSummary')?.deliveryCount ? 0 > 0 then 'locked'

  unlockBillExport: -> unless Session.get('metroSummary')?.saleCount ? 0 > 0 then 'locked'
  unlockImport: -> unless Session.get('metroSummary')?.warehouseCount ? 0 > 0 then 'locked'
  unlockStockManager: -> unless Session.get('metroSummary')?.importCount ? 0 > 0 then 'locked'
  unlockInventory: -> unless Session.get('metroSummary')?.importCount ? 0 > 0 then 'locked'
  unlockInventoryHistory: -> unless Session.get('metroSummary')?.inventoryCount ? 0 > 0 then 'locked'
  unlockInventoryReview: -> unless Session.get('metroSummary')?.inventoryCount ? 0 > 0 then 'locked'
  unlockInventoryIssue: -> unless Session.get('metroSummary')?.inventoryCount ? 0 > 0 then 'locked'
  unlockExport: -> unless Session.get('metroSummary')?.saleCount ? 0 > 0 then 'locked'


  unlockBranchManager: -> unless Session.get('metroSummary')?.merchantCount ? 0 > 0 then 'locked'
  unlockWarehouseManager: -> unless Session.get('metroSummary')?.warehouseCount ? 0 > 0 then 'locked'
  unlockTracker: -> unless Session.get('metroSummary')?.merchantCount ? 0 > 0 then 'locked'

