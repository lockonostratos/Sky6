formatWarehouseSearch = (item) -> "#{item.name}" if item
formatImportSearch = (item) -> "#{item.description}" if item
formatImportProductSearch = (item) -> "#{item.name} [#{item.skulls}]" if item
formatImportProviderSearch = (item) -> "#{item.name}" if item

runInitImportTracker = (context) ->
  return if Sky.global.importTracker
  Sky.global.importTracker = Tracker.autorun ->
    if currentProfile = Session.get('currentProfile')
      if currentProfile.currentWarehouse
        importHistory = Schema.imports.find({
          warehouse : Session.get('currentWarehouse')._id
          creator   : Meteor.userId()
          submited  : false
        }).fetch()
        (Session.set 'importHistory', importHistory) if importHistory

        if importHistory.length > 0
          currentImport = _.findWhere(importHistory, {_id: currentProfile.currentImport})
          if currentImport
            Session.set 'currentImport', currentImport
          else
            currentImport = importHistory[0]
            Session.set 'currentImport', currentImport
        else
          currentImport = Import.createdByWarehouseAndSelect(currentProfile.currentWarehouse, {description: 'New Import'})
        Session.set 'currentImportDetails', Schema.importDetails.find({import: currentImport._id}).fetch()

    if currentProductId = Session.get('currentImport')?.currentProduct
      if currentProduct = Schema.products.findOne(currentProductId)
        Session.setDefault 'currentProductInstance', currentProduct



Sky.appTemplate.extends Template.import,
  warehouseImport: -> Session.get 'currentImport'
  hideAddImportDetail: -> return "display: none" if Session.get('currentImport')?.finish == true
  hidePrice: -> return "display: none" if !Session.get('currentImport')?.currentPrice
  hideFinishImport: -> return "display: none" if Session.get('currentImport')?.finish == true || !(Session.get('currentImportDetails')?.length > 0)
  hideEditImport: -> return "display: none" if Session.get('currentImport')?.finish == false
  hideSubmitImport: -> return "display: none" if Session.get('currentImport')?.submited == true



  tabOptions:
    source: 'importHistory'
    currentSource: 'currentImport'
    caption: 'description'
    key: '_id'
    createAction  : -> Import.createdByWarehouseAndSelect(Session.get('currentWarehouse')._id, {description: 'new'})
    destroyAction : (instance) -> console.log Import.removeAll(instance._id)
    navigateAction: (instance) -> UserProfile.update {currentImport: instance._id}

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
      option =
        currentProduct     : e.added._id
        currentProvider    : e.added.provider ? 'skyReset'
        currentQuality     : 1
        currentImportPrice : e.added.importPrice ? 0
      if e.added.price > 0
        Schema.imports.update(Session.get('currentImport')._id, $set: option, $unset: {currentPrice: ""})
      else
        option.currentPrice = e.added.importPrice ? 0
        Schema.imports.update(Session.get('currentImport')._id, {$set: option})
      Session.set 'currentProductInstance', Schema.products.findOne(e.added._id)
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
    changeAction: (e) ->
      Schema.imports.update(Session.get('currentImport')._id, {$set: {currentProvider: e.added._id }})
      Schema.products.update(Session.get('currentProductInstance')._id, {$set:{provider: e.added._id}})
    reactiveValueGetter: -> Session.get('currentImport')?.currentProvider

  qualityOptions:
    reactiveSetter: (val) -> Schema.imports.update(Session.get('currentImport')._id, {$set: { currentQuality: val }})
    reactiveValue: -> Session.get('currentImport')?.currentQuality ? 0
    reactiveMax: -> 9999
    reactiveMin: -> 0
    reactiveStep: -> 1

  importPriceOptions:
    reactiveSetter: (val) ->
      Schema.imports.update(Session.get('currentImport')._id, {$set: { currentImportPrice: val }})
      Schema.products.update(Session.get('currentImport').currentProduct, {$set:{importPrice: val}})
    reactiveValue: -> Session.get('currentImport')?.currentImportPrice ? 0
    reactiveMax: -> 999999999
    reactiveMin: -> 0
    reactiveStep: -> 1000
    others:
      forcestepdivisibility: 'none'

  priceOptions:
    reactiveSetter: (val) ->
      if Session.get('currentImport').currentPrice
        Schema.imports.update(Session.get('currentImport')._id, {$set: { currentPrice: val }})
    reactiveValue: -> Session.get('currentImport')?.currentPrice ? 0
    reactiveMax: -> 999999999
    reactiveMin: ->
      if Session.get('currentImport')?.currentPrice
        return Session.get('currentImport')?.currentImportPrice
      else
        Number(0)

    reactiveStep: -> 1000
    others:
      forcestepdivisibility: 'none'

  importDetailOptions:
    itemTemplate: 'importProductThumbnail'
    reactiveSourceGetter: -> Session.get('currentImportDetails')
    wrapperClasses: 'detail-grid row'

  events:
    'click .addImportDetail': (event, template)-> console.log ImportDetail.createByImport Session.get('currentImport')._id
    'click .editImport': (event, template)-> console.log Import.editImport Session.get('currentImport')._id
    'click .finishImport': (event, template)-> console.log Import.finishImport Session.get('currentImport')._id
    'click .submitImport': (event, template)-> console.log Import.submitedImport Session.get('currentImport')._id
    'blur .description': (event, template)->
      if template.find(".description").value.length > 1
        Schema.imports.update(Session.get('currentImport')._id, {$set: {description: template.find(".description").value}})
      else
        template.find(".description").value = Session.get('currentImport').description
    'blur .deposit': (event, template)->
      if parseInt(template.find(".deposit").value) > 0
        if parseInt(template.find(".deposit").value) < Session.get('currentImport').totalPrice
          Schema.imports.update(Session.get('currentImport')._id, {$set: {
            deposit: parseInt(template.find(".deposit").value)
            debit: Session.get('currentImport').totalPrice - parseInt(template.find(".deposit").value)
          }})
        else
          Schema.imports.update(Session.get('currentImport')._id, {$set: {
            deposit: Session.get('currentImport').totalPrice
            debit: 0
          }})
          template.find(".deposit").value = Session.get('currentImport').totalPrice
      else
        Schema.imports.update(Session.get('currentImport')._id, {$set: {
          deposit: 0
          debit: Session.get('currentImport').totalPrice
        }})
        template.find(".deposit").value = 0



  rendered: -> runInitImportTracker()