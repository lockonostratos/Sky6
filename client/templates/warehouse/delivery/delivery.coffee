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
      Session.set "availableDeliveryMerchants", Schema.merchants.find({}).fetch()

    if Session.get('availableDeliveryMerchants')
      Session.set "currentDeliveryMerchant", Schema.merchants.findOne(Session.get('currentProfile').currentDeliveryMerchant)

    if Session.get('currentDeliveryMerchant')
      Session.set "availableDeliveryWarehouses", Schema.warehouses.find({merchant: Session.get('currentDeliveryMerchant')._id}).fetch()

    if Session.get('availableDeliveryWarehouses')
      Session.set "currentDeliveryWarehouse", Schema.warehouses.findOne(Session.get('currentProfile').currentDeliveryWarehouse) ? 'skyReset'

    if Session.get("currentDeliveryWarehouse") and Session.get("currentDeliveryWarehouse") != "skyReset"
      if Session.get('currentProfile')?.currentDeliveryFilter == 0
        Session.set "availableDeliveries", Schema.deliveries.find(
          warehouse: Session.get("currentDeliveryWarehouse")._id
          $or: [ {status: 0}, {shipper: Meteor.userId()} ]
        ).fetch()

      if Session.get('currentProfile')?.currentDeliveryFilter == 1
        Session.set "availableDeliveries", Schema.deliveries.find({
          warehouse: Session.get("currentDeliveryWarehouse")._id
          status: 0
        }).fetch()

      if Session.get('currentProfile')?.currentDeliveryFilter == 2
        Session.set "availableDeliveries", Schema.deliveries.find({
          warehouse: Session.get("currentDeliveryWarehouse")._id
          shipper: Meteor.userId()
          status: {$in:[1,2,3,4,5,7,8]}
        }).fetch()

      if Session.get('currentProfile')?.currentDeliveryFilter == 3
        Session.set "availableDeliveries", Schema.deliveries.find({
          warehouse: Session.get("currentDeliveryWarehouse")._id
          shipper: Meteor.userId()
          status: {$in:[6,9]}
        }).fetch()
    else
      Session.set "availableDeliveries", []


Sky.appTemplate.extends Template.delivery,
  deliverry: ->

  merchantSelectOptions:
    query: (query) -> query.callback
      results: _.filter Session.get('availableDeliveryMerchants'), (item) ->
        unsignedTerm = Sky.helpers.removeVnSigns query.term
        unsignedName = Sky.helpers.removeVnSigns item.name
        unsignedName.indexOf(unsignedTerm) > -1
    initSelection: (element, callback) -> callback(Session.get('currentDeliveryMerchant'))
    formatSelection: formatMerchantSearch
    formatResult: formatMerchantSearch
    placeholder: 'CHỌN CHI NHÁNH'
    changeAction: (e) ->
      Schema.userProfiles.update Session.get('currentProfile')._id, $set:
        currentDeliveryMerchant : e.added._id
        currentDeliveryWarehouse: Schema.warehouses.findOne(merchant: e.added._id)?._id  ? 'skyReset'
        currentDeliveryFilter   : 1
    reactiveValueGetter: -> Session.get('currentDeliveryMerchant')

  warehouseSelectOptions:
    query: (query) -> query.callback
      results: _.filter Session.get('availableDeliveryWarehouses'), (item) ->
        unsignedTerm = Sky.helpers.removeVnSigns query.term
        unsignedName = Sky.helpers.removeVnSigns item.name
        unsignedName.indexOf(unsignedTerm) > -1
    initSelection: (element, callback) -> callback(Session.get('currentDeliveryWarehouse'))
    formatSelection: formatWarehouseSearch
    formatResult: formatWarehouseSearch
    placeholder: 'CHỌN CHI NHÁNH'
    changeAction: (e) ->
      Schema.userProfiles.update Session.get('currentProfile')._id, $set:
        currentDeliveryWarehouse: e.added._id
        currentDeliveryFilter   : 1
    reactiveValueGetter: -> Session.get('currentDeliveryWarehouse')

  filterDeliverySelectOption:
    query: (query) -> query.callback
      results: Sky.system.filterDeliveries
      text: 'id'
    initSelection: (element, callback) -> callback _.findWhere(Sky.system.filterDeliveries, {_id: Session.get('currentProfile')?.currentDeliveryFilter})
    formatSelection: formatfilterDeliverySearch
    formatResult: formatfilterDeliverySearch
    placeholder: 'BỘ LỌC'
    minimumResultsForSearch: -1
    changeAction: (e) ->
      Schema.userProfiles.update Session.get('currentProfile')._id, $set:{currentDeliveryFilter: e.added._id}
    reactiveValueGetter: -> _.findWhere(Sky.system.filterDeliveries, {_id: Session.get('currentProfile')?.currentDeliveryFilter})

  deliveryDetailOptions:
    itemTemplate: 'deliveryThumbnail'
    reactiveSourceGetter: -> Session.get('availableDeliveries')
    wrapperClasses: 'detail-grid row'

  rendered: ->
    runInitDeliveryTracker()