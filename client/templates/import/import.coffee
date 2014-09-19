formatWarehouseSearch = (item) -> "#{item.name}" if item
formatImportSearch = (item) -> "#{item.description}" if item
formatImportProductSearch = (item) -> "#{item.name} [#{item.skulls}]" if item
formatImportProviderSearch = (item) -> "#{item.name}" if item

importCreator= ->
  currentWarehouse = Warehouse.findOne(Session.get('currentWarehouse')._id) if Session.get('currentWarehouse')
  currentWarehouse.addImport({description: 'new'})
importDetailCreator= ->
  currentImport = Import.findOne(Session.get('currentImport')._id) if Session.get('currentImport')
  currentImport.addImportDetail(Session.get('currentProductInstance'), Session.get('currentImportDetails'))
finishImport = ->
  currentImport = Import.findOne(Session.get('currentImport')._id) if Session.get('currentImport')
  currentImport.finishImport(Session.get('currentImportDetails'))


runInitImportTracker = (context) ->
  return if Sky.global.importTracker
  Sky.global.importTracker = Tracker.autorun ->
    if Session.get('currentWarehouse')
      Session.set 'importHistory', Schema.imports.find({warehouse: Session.get('currentWarehouse')._id, finish: false}).fetch()

    if Session.get('currentImport')
      Session.set('currentImportDetails', Schema.importDetails.find({import: Session.get('currentImport')._id}).fetch())
      Session.set 'currentProductInstance', Schema.products.findOne(Session.get('currentImport').currentProduct)

    currentImportId = Session.get('currentProfile')?.currentImport
    Session.set('currentImport', Schema.imports.findOne(currentImportId)) if currentImportId


Sky.appTemplate.extends Template.import,
  description: -> Session.get('currentImport')?.description

  tabOptions:
    source: 'importHistory'
    currentSource: 'currentImport'
    caption: 'description'
    key: '_id'
    createAction  : -> Import.createdByWarehouseAndSelect(Session.get('currentWarehouse')._id, {description: 'new'})
    destroyAction : (instance) -> Schema.imports.remove(instance._id)
#    navigateAction:

  productSelectOptions:
    query: (query) -> query.callback
      results: _.filter Session.get('availableProducts'), (item) ->
        unsignedTerm = Sky.helpers.removeVnSigns query.term
        unsignedName = Sky.helpers.removeVnSigns item.name

        unsignedName.indexOf(unsignedTerm) > -1 || item.productCode.indexOf(unsignedTerm) > -1
      text: 'name'
    initSelection: (element, callback) -> callback(Schema.products.findOne(Session.get('currentImport')?.currentProduct))
    formatSelection: formatImportProductSearch
    formatResult: formatImportProductSearch
    id: '_id'
    placeholder: 'CHỌN SẢN PHẨM'
#    minimumResultsForSearch: -1
    hotkey: 'return'
    changeAction: (e) ->
      Schema.imports.update(Session.get('currentImport')._id, {$set: {
        currentProduct: e.added._id
        currentProvider: 'skyReset'
        currentQuality: 1
        currentPrice  : 1000
      }})
    reactiveValueGetter: -> Session.get('currentImport')?.currentProduct

  providerSelectOptions:
    query: (query) -> query.callback
      results: _.filter Session.get('availableProviders'), (item) ->
        unsignedTerm = Sky.helpers.removeVnSigns query.term
        unsignedName = Sky.helpers.removeVnSigns item.name
        unsignedName.indexOf(unsignedTerm) > -1
      text: 'name'
    initSelection: (element, callback) -> callback(Schema.providers.findOne(Session.get('currentImport')?.currentProvider))
    formatSelection: formatImportProviderSearch
    formatResult: formatImportProviderSearch
    id: '_id'
    placeholder: 'CHỌN NHÀ CUNG CẤP'
#    minimumResultsForSearch: -1
    changeAction: (e) -> Schema.imports.update(Session.get('currentImport')._id, {$set: {currentProvider: e.added._id }})
    reactiveValueGetter: -> Session.get('currentImport')?.currentProvider

  qualityOptions:
    reactiveSetter: (val) -> Schema.imports.update(Session.get('currentImport')._id, {$set: { currentQuality: val }})
    reactiveValue: -> Session.get('currentImport')?.currentQuality ? 0
    reactiveMax: -> 99999
    reactiveMin: -> 0
    reactiveStep: -> 1

  importPriceOptions:
    reactiveSetter: (val) -> Schema.imports.update(Session.get('currentImport')._id, {$set: { currentPrice: val }})
    reactiveValue: -> Session.get('currentImport')?.currentPrice ? 0
    reactiveMax: -> 999999999
    reactiveMin: -> 0
    reactiveStep: -> 1000
    others:
      forcestepdivisibility: 'none'

  importDetailOptions:
    itemTemplate: 'importProductThumbnail'
    reactiveSourceGetter: -> Session.get('currentImportDetails')
    wrapperClasses: 'detail-grid'

  events:
    'click .addImportDetail': (event, template)-> importDetailCreator()
    'click .finishImport': (event, template)-> console.log finishImport()

  rendered: -> runInitImportTracker()