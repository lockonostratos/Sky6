formatMerchantSearch = (item) -> "#{item.name}" if item
formatWarehouseSearch = (item) -> "#{item.name}" if item
formatInventoryDetaileSearch = (item) -> "#{item.description}" if item

runInitInventoryHistoryTracker = (context) ->
  return if Sky.global.inventoryHistoryTracker
  Sky.global.inventoryHistoryTracker = Tracker.autorun ->
      if Session.get("allWarehouseInventory") and Session.get('currentProfile')
        currentInventoryWarehouse = _.findWhere(Session.get("allWarehouseInventory"), {_id: Session.get('currentProfile').inventoryWarehouse})
        if currentInventoryWarehouse
          Session.set "currentInventoryWarehouse", currentInventoryWarehouse
        else
          Session.set "currentInventoryWarehouse"

      if Session.get("currentInventoryWarehouse")
        inventories = Schema.inventories.find({warehouse: Session.get("currentInventoryWarehouse")._id}).fetch()
        if inventories.length > 0 then Session.set "availableInventories", inventories
        if inventories.length == 0 then Session.set "availableInventories"
#
      if Session.get("availableInventories") and Session.get('currentProfile')?.currentInventoryHistory
        currentInventory = Schema.inventories.findOne(Session.get('currentProfile').currentInventoryHistory)
        if currentInventory
          Session.set "currentInventoryHistory", currentInventory
        else
          Session.set "currentInventoryHistory"
      else
        Session.set "currentInventoryHistory"

      if Session.get "currentInventoryHistory"
        Session.set "currentInventoryDetail", Schema.inventoryDetails.find({inventory: currentInventory?._id}).fetch()
      else
        Session.set "currentInventoryDetail"

Sky.appTemplate.extends Template.inventoryHistory,
  merchantSelectOptions:
    query: (query) -> query.callback
      results: _.filter Session.get('allMerchantInventories'), (item) ->
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
        inventoryWarehouse: Schema.warehouses.findOne({merchant: e.added._id, isRoot: true})?._id  ? 'skyReset'
    reactiveValueGetter: -> Session.get('inventoryMerchant')

  warehouseSelectOptions:
    query: (query) -> query.callback
      results: _.filter Session.get('allWarehouseInventory'), (item) ->
        unsignedTerm = Sky.helpers.removeVnSigns query.term
        unsignedName = Sky.helpers.removeVnSigns item.name
        unsignedName.indexOf(unsignedTerm) > -1
    initSelection: (element, callback) -> callback(Session.get('currentInventoryWarehouse') ? 'skyReset')
    formatSelection: formatWarehouseSearch
    formatResult: formatWarehouseSearch
    placeholder: 'CHỌN CHI NHÁNH'
    minimumResultsForSearch: -1
    changeAction: (e) ->
      Schema.userProfiles.update Session.get('currentProfile')._id, $set:
        inventoryWarehouse: e.added._id
        currentInventory  : 'skyReset'
    reactiveValueGetter: -> Session.get('currentInventoryWarehouse') ? 'skyReset'

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
    others:
      allowClear: true
    changeAction: (e) ->
      if e.removed
        Session.set('currentInventoryHistory')
      else
        Schema.userProfiles.update Session.get('currentProfile')._id, $set:
          currentInventoryHistory: e.added._id
    reactiveValueGetter: -> Session.get('currentInventoryHistory') ? 'skyReset'

  inventoryDetailOptions:
    itemTemplate: 'inventoryHistoryThumbnail'
    reactiveSourceGetter: -> Session.get('currentInventoryDetail') ? []
    wrapperClasses: 'detail-grid row'

  rendered: ->
    runInitInventoryHistoryTracker()
