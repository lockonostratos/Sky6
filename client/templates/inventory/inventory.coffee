formatSaleReturnSearch = (item) -> "#{item.orderCode}" if item
formatReturnSearch = (item) -> "#{item.returnCode}" if item
formatReturnProductSearch = (item) ->
#  item.availableQuality = item.quality - item.returnQuality
  "#{item.name} [#{item.skulls}] - [#{item.discountPercent}% * #{item.quality}]" if item

runInitReturnsTracker = (context) ->
  return if Sky.global.returnTracker
  Sky.global.returnTracker = Tracker.autorun ->
    if Session.get('currentWarehouse')
      Session.set "availableSales", Schema.sales.find({warehouse: Session.get('currentWarehouse')._id}).fetch()
    if Session.get('currentProfile')?.currentSale
      Session.set 'currentSale', Schema.sales.findOne(Session.get('currentProfile')?.currentSale)
    if Session.get('currentSale')
      Session.set 'currentSaleProductDetails', Schema.saleDetails.find({sale: Session.get('currentSale')._id}).fetch()
      Session.set 'currentReturn', Schema.returns.findOne({
        sale    : Session.get('currentSale')._id
        creator : Meteor.userId()
      })
    if Session.get('currentSale')?.currentProductDetail
      Session.set 'currentProductDetail', Schema.saleDetails.findOne(Session.get('currentSale')?.currentProductDetail)
    if Session.get('currentReturn')
      Session.set ('currentReturnDetails'), Schema.returnDetails.find({returns: Session.get('currentReturn')._id}).fetch()



Sky.appTemplate.extends Template.inventory,
  saleSelectOptions:
    query: (query) -> query.callback
      results: _.filter Session.get('availableSales'), (item) ->
        unsignedTerm = Sky.helpers.removeVnSigns query.term
        unsignedName = Sky.helpers.removeVnSigns item.orderCode
        unsignedName.indexOf(unsignedTerm) > -1
      text: 'orderCode'
    initSelection: (element, callback) -> callback(Session.get 'currentSale')
    formatSelection: formatSaleReturnSearch
    formatResult: formatSaleReturnSearch
    id: '_id'
    placeholder: 'CHỌN PHIẾU BÁN HÀNG'
#    minimumResultsForSearch: -1
    changeAction: (e) -> Schema.userProfiles.update(Session.get('currentProfile')._id, {$set: {currentSale: e.added._id}})
    reactiveValueGetter: -> Session.get('currentProfile')?.currentSale

  returnProductSelectOptions:
    query: (query) -> query.callback
      results: _.filter Session.get('currentSaleProductDetails'), (item) ->
        unsignedTerm = Sky.helpers.removeVnSigns query.term
        unsignedName = Sky.helpers.removeVnSigns item.name
        unsignedName.indexOf(unsignedTerm) > -1
      text: 'name'
    initSelection: (element, callback) -> callback(Schema.saleDetails.findOne(Session.get('currentSale')?.currentProductDetail))
    formatSelection: formatReturnProductSearch
    formatResult: formatReturnProductSearch
    id: '_id'
    placeholder: 'CHỌN SẢN PHẨM'
#    minimumResultsForSearch: -1
    hotkey: 'return'
    changeAction: (e) -> Schema.sales.update(Session.get('currentSale')._id, {$set: {currentProductDetail: e.added._id}})
    reactiveValueGetter: -> Session.get('currentSale')?.currentProductDetail

  qualityOptions:
    reactiveSetter: (val) -> Schema.sales.update(Session.get('currentSale')._id, {$set: {currentQuality: val}})
    reactiveValue: -> Session.get('currentSale')?.currentQuality ? 0
    reactiveMax: -> (Session.get('currentProductDetail')?.quality? - Session.get('currentProductDetail')?.returnQuality) ? 0
    reactiveMin: -> 0
    reactiveStep: -> 1

  returnDetailOptions:
    itemTemplate: 'returnProductThumbnail'
    reactiveSourceGetter: -> Session.get('currentReturnDetails')
    wrapperClasses: 'detail-grid row'
  events:
    'click .addReturnDetail': (event, template)->
      currentSale = Sale.findOne(Session.get('currentSale')._id)
      currentSale.addReturnDetail()

    'click .finishReturn': (event, template)->
      currentSale = Sale.findOne(Session.get('currentSale')._id)
      currentSale.finishReturn()

    'click .editReturn': (event, template)->
      currentSale = Sale.findOne(Session.get('currentSale')._id)
      currentSale.editReturn()

    'click .submitReturn': (event, template)->
      currentSale = Sale.findOne(Session.get('currentSale')._id)
      currentSale.submitReturn()

  rendered: ->
    runInitReturnsTracker()
