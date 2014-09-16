formatSaleReturnSearch = (item) -> "#{item.orderCode}" if item
formatReturnSearch = (item) -> "#{item.returnCode}" if item
formatReturnProductSearch = (item) -> "#{item.name} [#{item.skulls}]" if item

runInitReturnsTracker = (context) ->
  return if Sky.global.returnTracker
  Sky.global.returnTracker = Tracker.autorun ->
    if Session.get('currentWarehouse')
      Session.set "availableSales", Schema.sales.find({warehouse: Session.get('currentWarehouse')._id}).fetch()
      Session.set 'returnHistory', Schema.returns.find({
        warehouse : Session.get('currentWarehouse')._id
        creator   : Meteor.userId()
      }).fetch()

    if Session.get('returnHistory')
      Session.set('currentReturn', Session.get('returnHistory')[0])

    if Session.get('currentReturn')
      Session.set('currentReturnDetails', Schema.returnDetails.find({return: Session.get('currentReturn')._id}).fetch())



Sky.appTemplate.extends Template.inventory,
  saleSelectOptions:
    query: (query) -> query.callback
      results: _.filter Session.get('availableSales'), (item) ->
        unsignedTerm = Sky.helpers.removeVnSigns query.term
        unsignedName = Sky.helpers.removeVnSigns item.orderCode
        unsignedName.indexOf(unsignedTerm) > -1
      text: 'orderCode'
    initSelection: (element, callback) -> callback()
    formatSelection: formatSaleReturnSearch
    formatResult: formatSaleReturnSearch
    id: '_id'
    placeholder: 'CHỌN PHIẾU BÁN HÀNG'
#    minimumResultsForSearch: -1
    changeAction: (e) -> Session.set 'currentSale', e.added._id
    reactiveValueGetter: -> 'skyReset'

  returnSelectOptions:
    query: (query) -> query.callback
      results: _.filter Session.get('returnHistory'), (item) ->
        unsignedTerm = Sky.helpers.removeVnSigns query.term
        unsignedName = Sky.helpers.removeVnSigns item.returnCode
        unsignedName.indexOf(unsignedTerm) > -1
      text: 'orderCode'
    initSelection: (element, callback) -> callback()
    formatSelection: formatReturnSearch
    formatResult: formatReturnSearch
    id: '_id'
    placeholder: 'CHỌN PHIẾU TRẢ HÀNG'
#    minimumResultsForSearch: -1
    changeAction: (e) -> Session.set 'currentSale', e.added._id
    reactiveValueGetter: -> 'skyReset'

  returnProductSelectOptions:
    query: (query) -> query.callback
      results: _.filter Session.get('availableProducts'), (item) ->
        unsignedTerm = Sky.helpers.removeVnSigns query.term
        unsignedName = Sky.helpers.removeVnSigns item.name

        unsignedName.indexOf(unsignedTerm) > -1 || item.productCode.indexOf(unsignedTerm) > -1
      text: 'name'
    initSelection: (element, callback) -> callback()
    formatSelection: formatReturnProductSearch
    formatResult: formatReturnProductSearch
    id: '_id'
    placeholder: 'CHỌN SẢN PHẨM'
#    minimumResultsForSearch: -1
    hotkey: 'return'
    changeAction: (e) ->
    reactiveValueGetter: ->

  qualityOptions:
    reactiveSetter: (val) ->
      Schema.orders.update(Session.get('currentOrder')._id, {$set: {currentQuality: val}}) if Session.get('currentOrder')
    reactiveValue: -> Session.get('currentOrder')?.currentQuality ? 0
    reactiveMax: -> Session.get('currentProductMaxQuality') ? 1
    reactiveMin: -> 0
    reactiveStep: -> 1


  events:

    'click .addReturn': (event, template)->
      if template.find(".comment").value.length > 10
        currentWarehouse = Warehouse.findOne(Session.get('currentWarehouse')._id)
        currentWarehouse.addReturn({comment: template.find(".comment").value, sale: Session.get('currentSale')})
      else
        console.log 'thông tin quá ngắn'

    'click .addReturnDetail': (event, template)->

  rendered: ->
    runInitReturnsTracker()
