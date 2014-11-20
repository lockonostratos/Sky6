formatWarehouseSearch = (item) -> "#{item.name}" if item
runInitStockManagerTracker = (context) ->
  return if Sky.global.stockManagerTracker
  Sky.global.stockManagerTracker = Tracker.autorun ->
    unless Session.get('currentStockWarehouse')
      Session.set('currentStockWarehouse', Session.get('currentWarehouse')) if Session.get('currentWarehouse')

    if Session.get('currentStockWarehouse')
      Session.set 'availableStockProducts', Schema.products.find({warehouse: Session.get('currentStockWarehouse')._id},Sky.helpers.defaultSort()).fetch()


Sky.appTemplate.extends Template.stockManager,
  totalStockProduct: ->
    if Session.get("availableStockProducts")
      total = 0
      for item in Session.get("availableStockProducts")
        total += item.inStockQuality
      total

  totalQualityProduct: ->
    if Session.get("availableStockProducts")
      total = 0
      for item in Session.get("availableStockProducts")
        total += item.totalQuality
      total

  totalProduct: -> Session.get("availableStockProducts")?.length

  warehouseSelectOptions:
    query: (query) -> query.callback
      results: _.filter Session.get('availableWarehouses'), (item) ->
        unsignedTerm = Sky.helpers.removeVnSigns query.term
        unsignedName = Sky.helpers.removeVnSigns item.name
        unsignedName.indexOf(unsignedTerm) > -1
    initSelection: (element, callback) -> callback(Session.get('currentStockWarehouse') ? 'skyReset')
    formatSelection: formatWarehouseSearch
    formatResult: formatWarehouseSearch
    placeholder: 'CHỌN CHI NHÁNH'
    minimumResultsForSearch: -1
    changeAction: (e) -> Session.set 'currentStockWarehouse', Schema.warehouses.findOne(e.added._id)
    reactiveValueGetter: -> Session.get('currentStockWarehouse') ? 'skyReset'

  stockDetailOptions:
    itemTemplate: 'stockThumbnail'
    reactiveSourceGetter: -> Session.get("availableStockProducts") ? []
    wrapperClasses: 'detail-grid row'

  created: ->
    Session.setDefault('currentStockWarehouse', Session.get('currentWarehouse'))

  rendered: -> runInitStockManagerTracker()
