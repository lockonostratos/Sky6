formatProductSearch = (item) -> "#{item.name} [#{item.skulls}]" if item
orderCreator = (merchantId, warehouseId)->
  newOrder =
    merchant      : Session.get('currentMerchant')._id
    warehouse     : Session.get('currentWarehouse')._id
    creator       : Meteor.userId()
    seller        : 'asdsad'
    buyer         : 'asdsad'
    orderCode     : 'asdsad'
    deliveryType  : 0
    paymentMethod : 0
    discountCash  : 0
    productCount  : 0
    saleCount     : 0
    totalPrice    : 0
    finalPrice    : 0
    deposit       : 0
    debit         : 0
    billDiscount  : false
    status        : 1
  newId = Schema.orders.insert newOrder
  newOrder._id = newId
  newOrder

Sky.template.extends Template.sales,
  orderDetails: -> Session.get('currentOrderDetails')
  fullName: -> Session.get('firstName') + ' ' + Session.get('lastName')
  firstName: -> Session.get('firstName')
  currentCaption: -> Session.get('currentOrder')?._id
  tabOptions:
    source: 'orderHistory'
    currentSource: 'currentOrder'
    caption: '_id'
    key: '_id'
    createAction: -> orderCreator()
    destroyAction: (instance) -> Schema.orders.remove(instance._id)
    navigateAction: (instance) ->

  productSelectOptions:
    query: (query) -> query.callback
      results: _.filter Session.get('availableProducts'), (item) ->
        unsignedTerm = Sky.helpers.removeVnSigns query.term
        unsignedName = Sky.helpers.removeVnSigns item.name

        unsignedName.indexOf(unsignedTerm) > -1 || item.productCode.indexOf(unsignedTerm) > -1
      text: 'name'
    initSelection: (element, callback) -> callback(Schema.products.findOne(Session.get('currentOrder')?.currentProduct))
    formatSelection: formatProductSearch
    formatResult: formatProductSearch
    id: '_id'
    placeholder: 'CHỌN SẢN PHẨM'
    hotkey: 'return'
    changeAction: (e) ->
      Schema.orders.update(Session.get('currentOrder')._id, {$set: {currentProduct: e.added._id}})
      Session.set('currentOrder', Schema.orders.findOne(Session.get('currentOrder')._id))
    reactiveValueGetter: -> Session.get('currentOrder')?.currentProduct

  saleDetailOptions:
    itemTemplate: 'testDyn'
    classicalHeader:
      columns: {name: 'Ho ten', price: 'Gia'}
    dataSource: [
      name: 'first item'
      price: 2000
    ,
      name: 'second item'
      price: 3000
    ]

  ui:
    productSelection: ".product-select2"