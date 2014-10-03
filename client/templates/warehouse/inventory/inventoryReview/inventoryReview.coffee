formatMerchantSearch = (item) -> "#{item.name}" if item
formatWarehouseSearch = (item) -> "#{item.name}" if item

runInitInventoryReviewTracker = (context) ->
  return if Sky.global.inventoryReviewTracker
  Sky.global.inventoryReviewTracker = Tracker.autorun ->
    if currentWarehouse = Session.get("inventoryWarehouse")
      inventories = Schema.inventories.find({warehouse: currentWarehouse._id}).fetch()
      if inventories.length > 0 then Session.set "availableInventories", inventories
      if inventories.length == 0 then Session.set "availableInventories"
    else
      Session.set "availableInventories"

Sky.appTemplate.extends Template.inventoryReview,
  merchantSelectOptions:
    query: (query) -> query.callback
      results: _.filter Session.get('allMerchantInventories'), (item) ->
        unsignedTerm = Sky.helpers.removeVnSigns query.term
        unsignedName = Sky.helpers.removeVnSigns item.name
        unsignedName.indexOf(unsignedTerm) > -1
    initSelection: (element, callback) -> callback(Session.get('inventoryMerchant') ? 'skyReset')
    formatSelection: formatMerchantSearch
    formatResult: formatMerchantSearch
    placeholder: 'CHỌN CHI NHÁNH'
    changeAction: (e) ->
      Schema.userProfiles.update Session.get('currentProfile')._id, $set:
        inventoryMerchant : e.added._id
        inventoryWarehouse: Schema.warehouses.findOne(merchant: e.added._id)?._id  ? 'skyReset'
    reactiveValueGetter: -> Session.get('inventoryMerchant') ? 'skyReset'

  warehouseSelectOptions:
    query: (query) -> query.callback
      results: _.filter Session.get('allWarehouseInventory'), (item) ->
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

  inventoryReviewsOptions:
    itemTemplate: 'inventoryThumbnail'
    reactiveSourceGetter: -> Session.get('availableInventories') ? []
    wrapperClasses: 'detail-grid row'

  rendered: ->
    runInitInventoryReviewTracker()
