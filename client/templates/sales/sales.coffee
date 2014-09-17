reloadOrderDetail = (template, disCash)->
  quality         = template.find(".quality").value         = calculationValueNumber(template.find(".quality").value, 1, 100)
  price           = template.find(".price").value           = calculationValueNumber(template.find(".price").value, 0)
  totalPrice      = template.find(".totalPrice").value      = quality * price
  if disCash
    discountCash    = template.find(".discountCash").value    = calculationValueNumber(template.find(".discountCash").value, 0, totalPrice)
    discountPercent = template.find(".discountPercent").value = discountCash/(totalPrice/100)
  else
    discountPercent = template.find(".discountPercent").value = calculationValueNumber(template.find(".discountPercent").value, 0, 100)
    discountCash    = template.find(".discountCash").value = (totalPrice/100)*discountPercent
  template.find(".finalPrice").value = totalPrice - discountCash

calculationValueNumber= (value, min, max)->
  temp = parseInt(value); min = parseInt(min); max = parseInt(max)
  return min if !temp || !temp || temp < min || max == min
  return max if max and temp > max
  return temp

formatProductSearch = (item) -> "#{item.name} [#{item.skulls}]" if item
formatSellerSearch = (item) -> "#{item.emails[0].address}" if item
formatCustomerSearch = (item) -> "#{item.name}" if item
formatpaymentMethodSearch = (item) -> "#{item.display}" if item

orderCreator = (merchantId, warehouseId) ->
  newOrder =
    merchant        : Session.get('currentMerchant')._id
    warehouse       : Session.get('currentWarehouse')._id
    creator         : Meteor.userId()
    seller          : Meteor.userId()
    currentProduct  : "null"
    currentQuality  : 0
    currentPrice    : 0
    currentDiscount : 0
    orderCode       : 'asdsad'
    deliveryType    : 0
    paymentMethod   : 0
    discountCash    : 0
    discountPercent : 0
    productCount    : 0
    saleCount       : 0
    totalPrice      : 0
    finalPrice      : 0
    deposit         : 0
    debit           : 0
    billDiscount    : false
    status          : 0
    currentDeposit  : 0

  newId = Schema.orders.insert newOrder
  newOrder._id = newId
  newOrder

maxQuality = ->
  qualityProduct = Session.get('currentProductInstance')?.availableQuality if Session.get('currentProductInstance')
  qualityOrderDetail = _.findWhere(Session.get('currentOrderDetails'), {product: Session.get('currentOrder').currentProduct})?.quality ? 0
  qualityProduct - qualityOrderDetail

calculateTotalPrice = -> Session.get('currentOrder')?.currentPrice * Session.get('currentOrder')?.currentQuality
calculatePercentDiscount = -> Math.round(Session.get('currentOrder')?.currentDiscount*100/(Session.get('currentOrder')?.currentPrice * Session.get('currentOrder')?.currentQuality))
calculateCashDiscount = (percentage)-> Math.floor(calculateTotalPrice() * (percentage / 100))

Session.set('dummyMax', 5)
Session.set('dummyQuality', 10)

runInitTracker = (context) ->
  return if Sky.global.saleTracker
  Sky.global.saleTracker = Tracker.autorun ->
    if Session.get('currentUser')
      Session.set "availableStaffSale", Meteor.users.find({}).fetch()
      Session.set "availableCustomerSale", Schema.customers.find({}).fetch()

    if Session.get('currentWarehouse')
      Session.set 'orderHistory', Schema.orders.find({warehouse: Session.get('currentWarehouse')._id}).fetch()

    if Session.get('currentOrder')
      Session.set('currentOrderDetails', Schema.orderDetails.find({order: Session.get('currentOrder')._id}).fetch())
      Session.set 'currentProductInstance', Schema.products.findOne(Session.get('currentOrder').currentProduct)

      Session.set 'currentProductMaxTotalPrice', calculateTotalPrice()
      Session.set 'currentProductMaxQuality', maxQuality()
      Session.set 'currentProductDiscountPercent', calculatePercentDiscount()

    currentOrderId = Session.get('currentProfile')?.currentOrder
    Session.set('currentOrder', Schema.orders.findOne(currentOrderId)) if currentOrderId

Sky.appTemplate.extends Template.sales,
  order: -> Session.get('currentOrder')
  currentOrderPercentDiscount: ->
    if Session.get('currentOrder')?.discountCash == 0
      return 0
    else
      return Math.round(Session.get('currentOrder')?.discountCash/Session.get('currentOrder')?.totalPrice*100)
  currentFinalPrice: -> (Session.get('currentOrder')?.currentPrice * Session.get('currentOrder')?.currentQuality) - Session.get('currentOrder')?.currentDiscount


  tabOptions:
    source: 'orderHistory'
    currentSource: 'currentOrder'
    caption: '_id'
    key: '_id'
    createAction: -> orderCreator()
    destroyAction: (instance) -> Order.remove(instance._id)
    navigateAction: (instance) ->
      Schema.userProfiles.update(Session.get('currentProfile')._id, {$set: {currentOrder: instance._id}})
#      console.log 'navigate of sales'
#      Meteor.call('updateAccount', {currentOrder: instance._id})
#      Meteor.users.update(Meteor.userId(), {$set: {currentOrder: instance._id}})

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
#    minimumResultsForSearch: -1
    hotkey: 'return'
    changeAction: (e) ->
      console.log e.added._id
      Schema.orders.update Session.get('currentOrder')._id,
        $set:
          currentProduct: e.added._id
          currentQuality: 1
          currentPrice: e.added.price
          currentDiscount: 0


    reactiveValueGetter: -> Session.get('currentOrder')?.currentProduct

  customerSelectOptions:
    query: (query) -> query.callback
      results: _.filter Session.get("availableCustomerSale"), (item) ->
        unsignedTerm = Sky.helpers.removeVnSigns query.term
        unsignedName = Sky.helpers.removeVnSigns item.name

        unsignedName.indexOf(unsignedTerm) > -1
      text: 'name'
    initSelection: (element, callback) -> callback(Schema.customers.findOne(Session.get('currentOrder')?.buyer))
    formatSelection: formatCustomerSearch
    formatResult: formatCustomerSearch
    id: '_id'
    placeholder: 'CHỌN NGƯỜI MUA'
    changeAction: (e) ->
      Schema.orders.update(Session.get('currentOrder')._id, {$set: {buyer: e.added._id}})
    reactiveValueGetter: -> Session.get('currentOrder')?.buyer

  sellerSelectOptions:
    query: (query) -> query.callback
      results: _.filter Session.get("availableStaffSale"), (item) ->
        result = false
        for email in item.emails
          if email.address.indexOf(query.term) > -1 then (result = true; break)
        result
      text: 'email'
    initSelection: (element, callback) ->
      currentSeller = Session.get('currentOrder')?.seller ? Meteor.userId()
      callback Meteor.users.findOne(currentSeller)

    formatSelection: formatSellerSearch
    formatResult: formatSellerSearch
    id: '_id'
    placeholder: 'CHỌN NGƯỜI BÁN'
    changeAction: (e) ->
      Schema.orders.update(Session.get('currentOrder')._id, {$set: {seller: e.added._id}})

    reactiveValueGetter: -> Session.get('currentOrder')?.seller

  paymentMethodSelectOption:
    query: (query) -> query.callback
      results: Sky.system.paymentMethods
      text: 'id'
    initSelection: (element, callback) -> callback _.findWhere(Sky.system.paymentMethods, {id: Session.get('currentOrder')?.paymentMethod})
    formatSelection: formatpaymentMethodSearch
    formatResult: formatpaymentMethodSearch
    placeholder: 'CHỌN SẢN PTGD'
    minimumResultsForSearch: -1
    changeAction: (e) ->
      Schema.orders.update(Session.get('currentOrder')._id, {$set: {paymentMethod: e.added.id}})
    reactiveValueGetter: -> _.findWhere(Sky.system.paymentMethods, {id: Session.get('currentOrder')?.paymentMethod})

  deliveryTypeSelectOption:
    query: (query) -> query.callback
      results: Sky.system.deliveryTypes
      text: 'id'
    initSelection: (element, callback) -> callback _.findWhere(Sky.system.deliveryTypes, {id: Session.get('currentOrder')?.deliveryType})
    formatSelection: formatpaymentMethodSearch
    formatResult: formatpaymentMethodSearch
    placeholder: 'CHỌN SẢN PTGD'
    minimumResultsForSearch: -1
    changeAction: (e) ->
      Schema.orders.update(Session.get('currentOrder')._id, {$set: {deliveryType: e.added.id}})
    reactiveValueGetter: -> _.findWhere(Sky.system.deliveryTypes, {id: Session.get('currentOrder')?.deliveryType})

  billDiscountSelectOption:
    query: (query) -> query.callback
      results: Sky.system.billDiscounts
      text: 'id'
    initSelection: (element, callback) -> callback _.findWhere(Sky.system.billDiscounts, {id: Session.get('currentOrder')?.billDiscount})
    formatSelection: formatpaymentMethodSearch
    formatResult: formatpaymentMethodSearch
    placeholder: 'CHỌN SẢN PTGD'
    minimumResultsForSearch: -1
    changeAction: (e) ->
      order = Order.findOne(Session.get('currentOrder')._id)
      option = {billDiscount: e.added.id}
      option.discountCash = 0 if option.billDiscount
      option.discountPercent = 0 if option.billDiscount
      Schema.orders.update(Session.get('currentOrder')._id, {$set: option})
      Sky.global.reCalculateOrder(Session.get('currentOrder')._id)

    reactiveValueGetter: -> _.findWhere(Sky.system.billDiscounts, {id: Session.get('currentOrder')?.billDiscount})

  saleDetailOptions:
    itemTemplate: 'saleProductThumbnail'
    reactiveSourceGetter: -> Session.get('currentOrderDetails')
    wrapperClasses: 'detail-grid row'

  qualityOptions:
    reactiveSetter: (val) ->
      Schema.orders.update(Session.get('currentOrder')._id, {$set: {currentQuality: val}}) if Session.get('currentOrder')
    reactiveValue: -> Session.get('currentOrder')?.currentQuality ? 0
    reactiveMax: -> Session.get('currentProductMaxQuality') ? 1
    reactiveMin: -> 0
    reactiveStep: -> 1

  priceOptions:
    reactiveSetter: (val)->
      Schema.orders.update(Session.get('currentOrder')._id, {$set: {currentPrice: val}}) if Session.get('currentOrder')
    reactiveValue: -> Session.get('currentOrder')?.currentPrice ? 0
    reactiveMax: -> 999999999
    reactiveMin: -> Session.get('currentProductInstance')?.price ? 0
    reactiveStep: -> 1000

  discountCashOptions:
    reactiveSetter: (val)->
      Schema.orders.update(Session.get('currentOrder')._id, {$set: {currentDiscount: val}}) if Session.get('currentOrder')
    reactiveValue: -> Session.get('currentOrder')?.currentDiscount ? 0
    reactiveMax: ->  Session.get('currentProductMaxTotalPrice') ? 0
    reactiveMin: -> 0
    reactiveStep: -> 1000
    others:
      forcestepdivisibility: 'none'

  discountPercentOptions:
    reactiveSetter: (val) ->
      Schema.orders.update(Session.get('currentOrder')._id, {$set: {currentDiscount: calculateCashDiscount(val)}}) if Session.get('currentOrder')
    reactiveValue: -> Session.get('currentProductDiscountPercent') ? 0
    reactiveMax: -> 100
    reactiveMin: -> 0
    reactiveStep: -> 1

  depositOptions:
    reactiveSetter: (val) ->
      if val > Session.get('currentOrder').finalPrice
        option=
          paymentMethod: 0
          deposit: Session.get('currentOrder').finalPrice
          debit: 0

        Schema.orders.update(Session.get('currentOrder')._id, {$set: option}) if Session.get('currentOrder')
      else
        option=
          paymentMethod: 1
          deposit: val
          debit: Session.get('currentOrder').finalPrice - val
        Schema.orders.update(Session.get('currentOrder')._id, {$set: option}) if Session.get('currentOrder')
    reactiveValue: -> Session.get('currentOrder')?.currentDeposit ? 0
    reactiveMax: -> 999999990
    reactiveMin: -> 0
    reactiveStep: -> 10000



  events:
    'click .addOrderDetail': (event, template)->
      order = Order.findOne(Session.get('currentOrder')._id)
      order.addOrderDetail(Session.get('currentProductInstance'), Session.get('currentOrderDetails'))

    'click .finish': (event, template)->
      order = Order.findOne(Session.get('currentOrder')._id)
      console.log order.finishOrder()

  rendered: ->
    runInitTracker()