formatMerchantSearch = (item) -> "#{item.name}" if item
formatWarehouseSearch = (item) -> "#{item.name}" if item

runInitInventoryReviewTracker = (context) ->
  return if Sky.global.inventoryReviewTracker
  Sky.global.inventoryReviewTracker = Tracker.autorun ->
    if Session.get('currentProfile')
      Session.set("availableInventoryReviewMerchants", Schema.merchants.find({}).fetch())

      currentMerchant = Schema.merchants.findOne(Session.get('currentProfile').inventoryReviewMerchant)
      currentWarehouse = Schema.warehouses.findOne(Session.get('currentProfile').inventoryReviewWarehouse)
      allWarehouse = Schema.warehouses.find({merchant: Session.get('currentProfile').inventoryReviewMerchant}).fetch()

      if currentMerchant then Session.set "currentInventoryReviewMerchant", currentMerchant
      else
        if Session.get("availableInventoryReviewMerchants").length > 0
          Session.set "currentInventoryReviewMerchant", Session.get("availableInventoryReviewMerchants")[0]
        else
          Session.set "currentInventoryReviewMerchant"

      if allWarehouse and Session.get('currentInventoryReviewMerchant')
        Session.set "availableInventoryReviewWarehouses", allWarehouse
      else
        allWarehouse = Schema.warehouses.find({merchant: Session.get('currentInventoryReviewMerchant')._id}).fetch()
        Session.set "availableInventoryReviewWarehouses", allWarehouse

      if currentWarehouse and Session.get("availableInventoryReviewWarehouses")

        Session.set "currentInventoryReviewWarehouse", currentWarehouse
      else
        if Session.get("availableInventoryReviewWarehouses").length > 0
          Session.set "currentInventoryReviewWarehouse", Session.get("availableInventoryReviewWarehouses")[0]
        else
          Session.set "currentInventoryReviewWarehouse", 'skyReset'

      if currentWarehouse = Session.get("currentInventoryReviewWarehouse")
        inventoryReviews = Schema.inventories.find({warehouse: currentWarehouse._id}).fetch()
        if inventoryReviews.length > 0
          Session.set "inventoryReviews", inventoryReviews
        else
          Session.set "inventoryReviews"


Sky.appTemplate.extends Template.inventoryReview,
  merchantSelectOptions:
    query: (query) -> query.callback
      results: _.filter Session.get('availableInventoryReviewMerchants'), (item) ->
        unsignedTerm = Sky.helpers.removeVnSigns query.term
        unsignedName = Sky.helpers.removeVnSigns item.name
        unsignedName.indexOf(unsignedTerm) > -1
    initSelection: (element, callback) -> callback(Session.get('currentInventoryReviewMerchant'))
    formatSelection: formatMerchantSearch
    formatResult: formatMerchantSearch
    placeholder: 'CHỌN CHI NHÁNH'
    changeAction: (e) ->
      Schema.userProfiles.update Session.get('currentProfile')._id, $set:
        inventoryReviewMerchant : e.added._id
        inventoryReviewWarehouse: Schema.warehouses.findOne(merchant: e.added._id)?._id  ? 'skyReset'
    reactiveValueGetter: -> Session.get('currentInventoryReviewMerchant')

  warehouseSelectOptions:
    query: (query) -> query.callback
      results: _.filter Session.get('availableInventoryReviewWarehouses'), (item) ->
        unsignedTerm = Sky.helpers.removeVnSigns query.term
        unsignedName = Sky.helpers.removeVnSigns item.name
        unsignedName.indexOf(unsignedTerm) > -1
    initSelection: (element, callback) -> callback(Session.get('currentInventoryReviewWarehouse') ? 'skyReset')
    formatSelection: formatWarehouseSearch
    formatResult: formatWarehouseSearch
    placeholder: 'CHỌN CHI NHÁNH'
    minimumResultsForSearch: -1
    changeAction: (e) ->
      Schema.userProfiles.update Session.get('currentProfile')._id, $set:
        inventoryReviewWarehouse: e.added._id
    reactiveValueGetter: -> Session.get('currentInventoryReviewWarehouse') ? 'skyReset'

  inventoryReviewsOptions:
    itemTemplate: 'inventoryThumbnail'
    reactiveSourceGetter: -> Session.get('inventoryReviews') ? []
    wrapperClasses: 'detail-grid row'

  rendered: ->
    runInitInventoryReviewTracker()
