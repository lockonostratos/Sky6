formatMerchantSearch = (item) -> "#{item.name}" if item
formatWarehouseSearch = (item) -> "#{item.name}" if item
formatInventoryDetaileSearch = (item) -> "#{item.description}" if item

runInitInventoryHistoryTracker = (context) ->
  return if Sky.global.inventoryHistoryTracker
  Sky.global.inventoryHistoryTracker = Tracker.autorun ->
      if currentWarehouse = Session.get("inventoryWarehouse")
        inventories = Schema.inventories.find({warehouse: currentWarehouse._id}).fetch()
        if inventories.length > 0 then Session.set "availableInventories", inventories
        if inventories.length == 0 then Session.set "availableInventories"

      if Session.get("availableInventories") and Session.get('currentProfile')?.currentInventoryHistory
        currentInventory = Schema.inventories.findOne(Session.get('currentProfile').currentInventoryHistory)
        Session.set "currentInventoryHistory", currentInventory
        Session.set "currentInventoryDetail", Schema.inventoryDetails.find({inventory: currentInventory?._id}).fetch()
      else
        Session.set "currentInventoryHistory"
        Session.set "currentInventoryDetail"

Sky.appTemplate.extends Template.inventoryHistory,
  merchantSelectOptions:
    query: (query) -> query.callback
      results: _.filter Session.get('availableMerchantInventories'), (item) ->
        unsignedTerm = Sky.helpers.removeVnSigns query.term
        unsignedName = Sky.helpers.removeVnSigns item.name
        unsignedName.indexOf(unsignedTerm) > -1
    initSelection: (element, callback) -> callback(Session.get('inventoryMerchant'))
    formatSelection: formatMerchantSearch
    formatResult: formatMerchantSearch
    placeholder: 'CHỌN CHI NHÁNH'
    changeAction: (e) ->
      Schema.userProfiles.update Session.get('currentProfile')._id, $set:
        inventoryMerchant : e.added._id
        inventoryWarehouse: Schema.warehouses.findOne(merchant: e.added._id)?._id  ? 'skyReset'
    reactiveValueGetter: -> Session.get('inventoryMerchant')

  warehouseSelectOptions:
    query: (query) -> query.callback
      results: _.filter Session.get('availableWarehouseInventories'), (item) ->
        unsignedTerm = Sky.helpers.removeVnSigns query.term
        unsignedName = Sky.helpers.removeVnSigns item.name
        unsignedName.indexOf(unsignedTerm) > -1
    initSelection: (element, callback) -> callback(Session.get('inventoryWarehouse') ? 'skyReset')
    formatSelection: formatWarehouseSearch
    formatResult: formatWarehouseSearch
    placeholder: 'CHỌN CHI NHÁNH'
    minimumResultsForSearch: -1
    changeAction: (e) ->
      Schema.userProfiles.update Session.get('currentProfile')._id, $set:
        inventoryWarehouse: e.added._id
    reactiveValueGetter: -> Session.get('inventoryWarehouse') ? 'skyReset'

  inventoryDetailSelectOptions:
    query: (query) -> query.callback
      results: _.filter Session.get('availableInventories'), (item) ->
        unsignedTerm = Sky.helpers.removeVnSigns query.term
        unsignedName = Sky.helpers.removeVnSigns item.description
        unsignedName.indexOf(unsignedTerm) > -1
    initSelection: (element, callback) -> callback(Session.get('currentInventoryHistory') ? 'skyReset')
    formatSelection: formatInventoryDetaileSearch
    formatResult: formatInventoryDetaileSearch
    placeholder: 'CHỌN PHIẾU KIỂM KHO'
    minimumResultsForSearch: -1
    changeAction: (e) ->
      Schema.userProfiles.update Session.get('currentProfile')._id, $set:
        currentInventoryHistory: e.added._id
    reactiveValueGetter: -> Session.get('currentInventoryHistory') ? 'skyReset'

  inventoryDetailOptions:
    itemTemplate: 'inventoryHistoryThumbnail'
    reactiveSourceGetter: -> Session.get('currentInventoryDetail') ? []
    wrapperClasses: 'detail-grid row'

  rendered: ->
    runInitInventoryHistoryTracker()
