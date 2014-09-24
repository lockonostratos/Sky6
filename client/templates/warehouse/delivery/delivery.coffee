updateDelyvery= (delivery, value)->
  item = Schema.deliveries.findOne(delivery._id)
  if item.status == 0 and value == 0
    Schema.deliveries.update item._id, $set:{status: 1, shipper: Meteor.userId()}; return
  if item.status == 1 and value == 0
    Schema.deliveries.update item._id, $set:{status: 2, exporter: Meteor.userId()}; return
  if item.status == 2 and value == 0
    Schema.deliveries.update item._id, $set:{status: 3}; return

  #Giao Hang Thanh Cong
  if item.status == 3 and value == 1
    Schema.deliveries.update item._id, $set:{status: 4}; return
  if item.status == 4 and value == 0
    Schema.deliveries.update item._id, $set:{status: 5, cashier: Meteor.userId()}; return
  if item.status == 5 and value == 0 then updateDeliveryTrue item

  #Giao Hang That Bai
  if item.status == 3 and value == 2
    Schema.deliveries.update item._id, $set:{status: 7}; return
  if item.status == 7 and value == 0
    Schema.deliveries.update item._id, $set:{status: 8, importer: Meteor.userId()}; return
  if item.status == 8 and value == 0
    Schema.deliveries.update item._id, $set:{status: 9}
    updateDeliveryFalse item
updateDeliveryTrue= (item) ->
  saleDetails = Schema.saleDetails.find({sale: item.sale}).fetch()
  for saleDetail in saleDetails
    productDetail = Schema.productDetails.findOne(saleDetail.productDetail)
    Schema.productDetails.update saleDetail.productDetail, $inc: {instockQuality: -saleDetail.quality}
    Schema.products.update productDetail.product, $inc: {instockQuality: -saleDetail.quality}
  Schema.sales.update item.sale, $set:{status: true}
  Schema.deliveries.update item._id, $set:{status: 6}
#chưa cập nhật vào bảng MetroSummary

updateDeliveryFalse= (item) ->
  saleDetails = Schema.saleDetails.find({sale: item.sale}).fetch()
  for saleDetail in saleDetails
    productDetail = Schema.productDetails.findOne(saleDetail.productDetail)
    Schema.productDetails.update saleDetail.productDetail, $inc: {availableQuality: saleDetail.quality}
    Schema.products.update productDetail.product, $inc: {availableQuality: saleDetail.quality}
  Schema.sales.update item.sale, $set:{status: false}
  Schema.deliveries.update item._id, $set:{status: 9}
#chưa cập nhật vào bảng MetroSummary

formatMerchantSearch = (item) -> "#{item.name}" if item
formatWarehouseSearch = (item) -> "#{item.name}" if item
formatfilterDeliverySearch = (item) -> "#{item.display}" if item

runInitDeliveryTracker = (context) ->
  return if Sky.global.deliveryTracker
  Sky.global.deliveryTracker = Tracker.autorun ->
    if Session.get('currentProfile')
      Session.set "availableDeliveryMerchant", Schema.merchants.find({}).fetch()

    if Session.get('availableDeliveryMerchant')
      Session.set "availableDeliveryWarehouse", Schema.warehouses.find({}).fetch()
      Session.set "currentDeliveryMerchant", Session.get('availableMerchantDelivery')[0]

    if Session.get('availableDeliveryWarehouse')
      Session.set "currentDeliveryWarehouse", Session.get('availableMerchantDelivery')[0]


Sky.appTemplate.extends Template.delivery,
  deliverry: ->

  merchantSelectOptions:
    query: (query) -> query.callback
      results: _.filter Session.get('availableMerchant'), (item) ->
        unsignedTerm = Sky.helpers.removeVnSigns query.term
        unsignedName = Sky.helpers.removeVnSigns item.name
        unsignedName.indexOf(unsignedTerm) > -1
      text: 'orderCode'
    initSelection: (element, callback) -> callback()
    formatSelection: formatMerchantSearch
    formatResult: formatMerchantSearch
    placeholder: 'CHỌN CHI NHÁNH'
    changeAction: (e) ->
    reactiveValueGetter: ->

  warehouseSelectOptions:
    query: (query) -> query.callback
      results: _.filter Session.get('availableMerchant'), (item) ->
        unsignedTerm = Sky.helpers.removeVnSigns query.term
        unsignedName = Sky.helpers.removeVnSigns item.name
        unsignedName.indexOf(unsignedTerm) > -1
      text: 'orderCode'
    initSelection: (element, callback) -> callback()
    formatSelection: formatWarehouseSearch
    formatResult: formatWarehouseSearch
    placeholder: 'CHỌN CHI NHÁNH'
    changeAction: (e) ->
    reactiveValueGetter: ->

  filterDeliverySelectOption:
    query: (query) -> query.callback
      results: Sky.system.filterDeliveries
      text: 'id'
    initSelection: (element, callback) -> callback _.findWhere(Sky.system.filterDeliveries, {_id: Session.get('currentOrder')?.billDiscount})
    formatSelection: formatfilterDeliverySearch
    formatResult: formatfilterDeliverySearch
    placeholder: 'BỘ LỌC'
    minimumResultsForSearch: -1
    changeAction: (e) ->
    reactiveValueGetter: -> _.findWhere(Sky.system.filterDeliveries, {_id: Session.get('currentOrder')?.billDiscount})


#  events:
#    'click .createDelivery':  (event, template)-> console.log 'create Delyverty'
#    'click .reactive-table .checkingDelivery': -> updateDelyvery @, 0
#    'click .reactive-table .trueDelivery': -> updateDelyvery @, 1
#    'click .reactive-table .falesDelivery': -> updateDelyvery @, 2
#    'click .reactive-table .resetDelivery': -> Schema.deliveries.update @_id, $set:{status: 0, shipper: undefined }
  rendered: ->
    runInitDeliveryTracker()