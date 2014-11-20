#--------------Format option-------------------------------------------->
formatProductSearch = (item) -> "#{item.name} [#{item.skulls}]" if item
formatSellerSearch = (item) -> "#{item.emails[0].address}" if item
formatCustomerSearch = (item) -> "#{item.name}" if item
formatPaymentMethodSearch = (item) -> "#{item.display}" if item
formatWarehouseSearch = (item) -> "#{item.name}" if item

#--------------Helper-------------------------------------------->
calculateCurrentOrderPercentDiscount= (currentOrder)->
  if currentOrder.discountCash is 0 then 0
  else Math.round(currentOrder.discountCash/currentOrder.totalPrice*100)

loadDeliverDetail = (currentOrder)->
  if currentOrder.paymentsDelivery is 1
    {
    contactName     : currentOrder.contactName
    contactPhone    : currentOrder.contactPhone
    deliveryAddress : currentOrder.deliveryAddress
    deliveryDate    : currentOrder.deliveryDate
    comment         : currentOrder.comment
    }
  else {}

calculateCurrentDebit = (currentOrder)->
  switch currentOrder.paymentMethod
    when 0 then currentOrder.currentDeposit - currentOrder.finalPrice
    when 1 then 0

calculateCurrentFinalPrice = (currentOrder)->
  totalPrice = Session.get('currentOrder')?.currentPrice * Session.get('currentOrder')?.currentQuality
  totalPrice - Session.get('currentOrder')?.currentDiscountCash

#---------------Tracker Autorun------------------------------>
calculateTotalPrice = -> Session.get('currentOrder')?.currentPrice * Session.get('currentOrder')?.currentQuality
calculatePercentDiscount = -> Math.round(Session.get('currentOrder')?.currentDiscount*100/(Session.get('currentOrder')?.currentPrice * Session.get('currentOrder')?.currentQuality))

maxQuality = ->
  qualityProduct = Session.get('currentProductInstance')?.availableQuality if Session.get('currentProductInstance')
  qualityOrderDetail = _.findWhere(Session.get('currentOrderDetails'), {product: Session.get('currentOrder').currentProduct})?.quality ? 0
  max = qualityProduct - qualityOrderDetail
  max

#--------------Event Blur-------------------------------------------->
checkingContactNameAndReUpdateOrder = (event, template)->
  contactName = template.find(".contactName").value
  if contactName.length > 1 then Sky.global.currentOrder.updateContactName(contactName.value)
  else contactName.value = Session.get('currentOrder').contactName

checkingContactPhoneAndReUpdateOrder = (event, template)->
  contactPhone = template.find(".contactPhone")
  if contactPhone.value.length > 1 then Sky.global.currentOrder.updateContactPhone(contactPhone.value)
  else contactPhone.value = Session.get('currentOrder').contactPhone

checkingDeliveryAddressAndReUpdateOrder = (event, template)->
  deliveryAddress = template.find(".deliveryAddress")
  if deliveryAddress.value.length > 1 then Sky.global.currentOrder.updateDeliveryAddress(deliveryAddress.value)
  else deliveryAddress.value = Session.get('currentOrder').deliveryAddress

checkingCommentAndReUpdateOrder = (event, template)->
  comment = template.find(".comment")
  if comment.value.length > 1 then Sky.global.currentOrder.updateComment(comment.value)
  else comment.value = Session.get('currentOrder').comment

#--------------reCalculateOrder-------------------------------------------->
calculateDepositAndDebitByProduct = (order, orderUpdate)->
  if order.currentDeposit == order.finalPrice
    orderUpdate.currentDeposit = orderUpdate.finalPrice

  if order.currentDeposit > orderUpdate.finalPrice
    orderUpdate.currentDeposit = order.currentDeposit

  if order.currentDeposit < orderUpdate.finalPrice
    orderUpdate.currentDeposit = orderUpdate.finalPrice

  orderUpdate.deposit = orderUpdate.finalPrice
  orderUpdate.debit = 0
  orderUpdate

calculateDepositAndDebitByBill = (order, orderUpdate)->
  if order.currentDeposit >= orderUpdate.finalPrice
    orderUpdate.paymentMethod = 0
    orderUpdate.deposit = orderUpdate.finalPrice
    orderUpdate.debit = 0
  else
    orderUpdate.deposit = order.currentDeposit
    orderUpdate.debit = orderUpdate.finalPrice - order.currentDeposit
  orderUpdate

calculateOrderDeposit= (order, orderOptionDefault)->
  switch order.paymentMethod
    when 0 then calculateDepositAndDebitByProduct(order, orderOptionDefault) #Tính theo từng sp
    when 1 then calculateDepositAndDebitByBill(order, orderOptionDefault) #Tính theo tổng bill

calculateDefaultOrder = (order, orderDetails)->
  orderUpdate =
    saleCount       :0
    discountCash    :0
    discountPercent :0
    totalPrice      :0

  for detail in orderDetails
    orderUpdate.totalPrice += detail.quality * detail.price
    orderUpdate.saleCount += detail.quality
    if order.billDiscount
      orderUpdate.discountCash = orderUpdate.discountCash
    else
      orderUpdate.discountCash += detail.discountCash
  orderUpdate.discountPercent = orderUpdate.discountCash/orderUpdate.totalPrice*100
  orderUpdate.finalPrice      = orderUpdate.totalPrice - orderUpdate.discountCash
  orderUpdate

updateOrderByOrderDetail = (order, orderDetails)->
  orderOptionDefault = calculateDefaultOrder(order, orderDetails)
  updateOrder = calculateOrderDeposit(order ,orderOptionDefault)
  Schema.orders.update order._id, $set: updateOrder

updateOrderByOrderDetailEmpty = (orderId)->
  updateOrder =
    saleCount       : 0
    discountCash    : 0
    discountPercent : 0
    totalPrice      : 0
    finalPrice      : 0
    paymentMethod   : 0
    currentDeposit  : 0
    deposit         : 0
    debit           : 0

  Schema.orders.update orderId, $set: updateOrder

reCalculateOrder = (order)->
  orderDetails = Schema.orderDetails.find({order: order._id}).fetch()
  if orderDetails.length > 0
    updateOrderByOrderDetail(order, orderDetails)
  else
    updateOrderByOrderDetailEmpty(order._id)
#-------------------------------------------------------------------------------->

reUpdateOrderDetail = (newOrderDetail, oldOrderDetail) ->
  option={}
  option.quality      = oldOrderDetail.quality + newOrderDetail.quality
  option.totalPrice   = option.quality * oldOrderDetail.price
  option.discountCash = Math.round(option.totalPrice * oldOrderDetail.discountPercent/100)
  option.finalPrice   = option.totalPrice - option.discountCash

  Schema.orderDetails.update oldOrderDetail._id, $set: option , (error, result) -> console.log error if error

checkingValueNewOrderDetail = (order)->
    unless product = Schema.products.findOne(order.currentProduct)
      console.log 'Chưa chọn sản phẩm'
      return false
    else if order.currentQuality == 0
      console.log 'Số lượng phải lớn hơn 0'
      return false
    else if order.currentPrice == 0
      console.log 'Giá sản phẩm phải lớn hơn 0'
      return false
    else if order.currentPrice < product.price
      console.log 'Giá sản phẩm phải lớn hơn giá nhập'
      return false
    else
      return true

addOrderDetail= (orderDetail, orderDetails)->
  findOrderDetailOld =_.findWhere(orderDetails,
    {
      product         : orderDetail.product
      price           : orderDetail.price
      discountPercent : orderDetail.discountPercent
    })
  if findOrderDetailOld
    reUpdateOrderDetail(orderDetail, findOrderDetailOld)
  else
    Schema.orderDetails.insert orderDetail, (error, result) -> console.log error if error

addOrderDetailAndCalculateOrder = (order)->
  orderDetails = Schema.orderDetails.find({order: order._id}).fetch()
  orderDetail = OrderDetail.newByOrder(order)

  addOrderDetail(orderDetail, orderDetails)
  reCalculateOrder(order)

checkingAndAddOrderDetail = (event, template)->
  currentOrder = Order.findOne(Sky.global.currentOrder.id)
  if checkingValueNewOrderDetail(currentOrder.data)
    addOrderDetailAndCalculateOrder(currentOrder.data)
#--------------Event Click Finish-------------------------------------------->
subtractQualityOnSales = (stockingItems, sellingItem , currentSale) ->
  transactionQuality = 0
  for productDetail in stockingItems
    requiredQuality = sellingItem.quality - transactionQuality
    if productDetail.availableQuality > requiredQuality
      takenQuality = requiredQuality
    else
      takenQuality = productDetail.availableQuality

    SaleDetail.createSaleDetailByOrder(currentSale, sellingItem, productDetail, takenQuality)
    Schema.productDetails.update productDetail._id, $inc:{availableQuality: -takenQuality}
    Schema.products.update productDetail.product  , $inc:{availableQuality: -takenQuality}

    transactionQuality += takenQuality
    if transactionQuality == sellingItem.quality then break
  return transactionQuality == sellingItem.quality

checkProductInStockQuality = (order, orderDetails)-> #----ok------->
  product_ids = _.union(_.pluck(orderDetails, 'product'))
  products = Schema.products.find({_id: {$in: product_ids}}).fetch()

  orderDetails = _.chain(orderDetails)
  .groupBy("product")
  .map (group, key) ->
    return {
    product: key
    quality: _.reduce(group, ((res, current) -> res + current.quality), 0)
    }
  .value()
  try
    for currentDetail in orderDetails
      currentProduct = _.findWhere(products, {_id: currentDetail.product})
      if currentProduct.availableQuality < currentDetail.quality
        throw {message: "lỗi", item: currentDetail}

    return {}
  catch e
    return {error: e}

createSaleAndSaleOrder = (order, orderDetails)->
  unless currentSale = Sale.findOne(Sale.insertByOrder(order)) then return null
  for currentOrderDetail in orderDetails
    productDetails = Schema.productDetails.find({product: currentOrderDetail.product}).fetch()
    subtractQualityOnSales(productDetails, currentOrderDetail, currentSale.data)

  option = {status: true}
  if currentSale.data.paymentsDelivery == 1
    option.delivery = Delivery.insertBySale(order, currentSale.data)
  Schema.sales.update currentSale.id, $set: option, (error, result) ->
    if error then console.log error
  currentSale.id

removeOrderAndOrderDetailAfterCreateSale = (orderId)->
  userProfile = Schema.userProfiles.findOne({user: Meteor.userId()})
  allTabs = Schema.orders.find(
    {
      creator   : userProfile.user
      merchant  : userProfile.currentMerchant
      warehouse : userProfile.currentWarehouse
    }).fetch()
  currentSource = _.findWhere(allTabs, {_id: userProfile.currentOrder})
  currentIndex = allTabs.indexOf(currentSource)
  currentLength = allTabs.length
  console.log currentIndex
  if currentLength > 1
    if currentLength is currentIndex+1
      UserProfile.update {currentOrder: allTabs[currentIndex-1]._id}
    else
      console.log allTabs[currentIndex+1]
      UserProfile.update {currentOrder: allTabs[currentIndex+1]._id}
    Order.removeAllOrderDetail(orderId)
  else
    Order.createOrderAndSelect()
    Order.removeAllOrderDetail(orderId)


calculateAndFinishOrder = (order, orderDetails)->
  result = checkProductInStockQuality(order, orderDetails)
  if result.error then console.log result.error

  saleId = createSaleAndSaleOrder(order, orderDetails)

  removeOrderAndOrderDetailAfterCreateSale(order._id)
  Notification.newSaleDefault(saleId)

checkingPaymentsDelivery = (event, template)->
  if Sky.global.currentOrder.data.paymentsDelivery is 1
    expire = template.ui.$deliveryDate.data('datepicker').dates[0]
    Sky.global.currentOrder.updateDeliveryDate(expire)

checkingPaymentsDeliveryAndFinishOrder = (event, template) ->
  currentOrder        = Order.findOne(Sky.global.currentOrder.id).data
  currentOrderDetails = OrderDetail.find({order: Sky.global.currentOrder.id}).data.fetch()

  checkingPaymentsDelivery(event, template)
  calculateAndFinishOrder(currentOrder, currentOrderDetails)

#--------------runInitTracker-------------------------------------------->
runInitTracker = (context) ->
  return if Sky.global.saleTracker
  Sky.global.saleTracker = Tracker.autorun ->
    if Session.get('currentMerchant')
      Session.set "availableStaffSale", Meteor.users.find({}).fetch()
      if Session.get('currentMerchant').parent
        merchant = Session.get('currentMerchant').parent
      else
        merchant = Session.get('currentMerchant')._id
      Session.set "availableCustomerSale", Schema.customers.find({parentMerchant: merchant}).fetch()

    if Session.get('currentWarehouse') and Session.get('currentProfile')?.currentOrder
      orderHistory =  Schema.orders.find({
        merchant: Session.get('currentMerchant')._id
        warehouse: Session.get('currentWarehouse')._id
        creator: Meteor.userId()
      }).fetch()
      Session.set 'orderHistory', orderHistory
      if orderHistory.length > 0
        order = _.findWhere(orderHistory, {_id: Session.get('currentProfile').currentOrder})
        if order
          Sky.global.currentOrder = Order.findOne(order._id)
          Session.set 'currentOrder', Sky.global.currentOrder.data
        else
          Sky.global.currentOrder = Order.findOne(orderHistory[0]._id)
          Session.set 'currentOrder', Sky.global.currentOrder.data
      else
#        Order.createOrderAndSelect()

    if Session.get('currentOrder')
      Session.set 'currentOrderDetails', Schema.orderDetails.find({order: Session.get('currentOrder')._id}).fetch()
      Session.set 'currentProductInstance', Schema.products.findOne(Session.get('currentOrder').currentProduct)

      Session.set 'currentProductMaxTotalPrice', calculateTotalPrice()
      Session.set 'currentProductMaxQuality', maxQuality()
      Session.set 'currentProductDiscountPercent', calculatePercentDiscount()

    if Session.get('currentOrder')?.buyer and Session.get('currentMerchant')?.parentMerchant
      buyer = Schema.customers.findOne({
        _id: Session.get('currentOrder').buyer
        parentMerchant: Session.get('currentMerchant').parentMerchant
      })
      (Session.set 'currentCustomerSale', buyer) if buyer

    if Session.get('currentOrder')?.currentProduct
      if Schema.products.findOne({_id: Session.get('currentOrder').currentProduct, warehouse: Session.get('currentOrder').warehouse})
        Session.set('allowAllOrderDetail', true) unless Session.get('allowAllOrderDetail')
      else
        Session.set('allowAllOrderDetail', false) if Session.get('allowAllOrderDetail')

    if Session.get('currentOrderDetails')?.length > 0
      Session.set('allowSuccessOrder', true) unless Session.get('allowSuccessOrder')
    else
      Session.set('allowSuccessOrder', false) if Session.get('allowSuccessOrder')


    if Sky.global.salesTemplateInstance
      if Session.get('currentOrder')?.paymentsDelivery == 0 || Session.get('currentOrder')?.paymentsDelivery == 2
        Sky.global.salesTemplateInstance.ui.extras.toggleExtra 'delivery', false
      else
        Sky.global.salesTemplateInstance.ui.extras.toggleExtra 'delivery'

Sky.appTemplate.extends Template.sales,
  order: -> Session.get('currentOrder')
  allowAllOrderDetail: -> unless Session.get('allowAllOrderDetail') then 'disabled'
  allowSuccessOrder: -> unless Session.get('allowSuccessOrder') then 'disabled'
  formatNumber: (number) -> accounting.formatNumber(number)

  currentFinalPrice: -> calculateCurrentFinalPrice(Session.get('currentOrder')) if Session.get('currentOrder')
  delivery: -> loadDeliverDetail(Session.get('currentOrder')) if Session.get('currentOrder')
  currentOrderPercentDiscount: -> calculateCurrentOrderPercentDiscount(Session.get('currentOrder')) if Session.get('currentOrder')
  currentDebit: ->  calculateCurrentDebit(Session.get('currentOrder')) if Session.get('currentOrder')

  created: ->
    Session.setDefault('allowAllOrderDetail', false)
    Session.setDefault('allowSuccessOrder', false)

  rendered: ->
    Sky.global.salesTemplateInstance = @
    runInitTracker()
    @ui.$deliveryDate.datepicker
      language: "vi"

  events:
    "change [name='advancedMode']": (event, template) ->
      Sky.global.salesTemplateInstance.ui.extras.toggleExtra 'advanced', event.target.checked

    'blur .contactName'     : (event, template)-> checkingContactNameAndReUpdateOrder(event, template)
    'blur .contactPhone'    : (event, template)-> checkingContactPhoneAndReUpdateOrder(event, template)
    'blur .deliveryAddress' : (event, template)-> checkingDeliveryAddressAndReUpdateOrder(event, template)
    'blur .comment'         : (event, template)-> checkingCommentAndReUpdateOrder(event, template)
    'click .addOrderDetail' : (event, template)-> checkingAndAddOrderDetail(event, template)
    'click .finish'         : (event, template)-> checkingPaymentsDeliveryAndFinishOrder(event, template)

  tabOptions:
    source: 'orderHistory'
    currentSource: 'currentOrder'
    caption: 'tabDisplay'
    key: '_id'
    createAction: -> Order.createOrderAndSelect()
    destroyAction: (instance) -> Order.removeAllOrderDetail(instance._id)
    navigateAction: (instance) -> UserProfile.update {currentOrder: instance._id}

  saleDetailOptions:
    itemTemplate: 'saleProductThumbnail'
    reactiveSourceGetter: -> Session.get('currentOrderDetails')
    wrapperClasses: 'detail-grid row'

  warehouseSelectOptions:
    query: (query) -> query.callback
      results: _.filter Session.get('availableWarehouses'), (item) ->
        unsignedTerm = Sky.helpers.removeVnSigns query.term
        unsignedName = Sky.helpers.removeVnSigns item.name
        unsignedName.indexOf(unsignedTerm) > -1
    initSelection: (element, callback) -> callback(Session.get('currentWarehouse') ? 'skyReset')
    formatSelection: formatWarehouseSearch
    formatResult: formatWarehouseSearch
    placeholder: 'CHỌN CHI NHÁNH'
    minimumResultsForSearch: -1
    changeAction: (e) ->
      Schema.userProfiles.update Session.get('currentProfile')._id, $set: {currentWarehouse: e.added._id}
    reactiveValueGetter: -> Session.get('currentWarehouse') ? 'skyReset'

  productSelectOptions:
    query: (query) -> query.callback
      results: _.filter Session.get('availableSaleProducts'), (item) ->
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
      unless Session.get('currentOrder') then Session.set('currentOrder', Order.createOrderAndSelect())
      Schema.orders.update Session.get('currentOrder')._id,
        $set:
          currentProduct        : e.added._id
          currentQuality        : Number(1)
          currentPrice          : e.added.price
          currentDiscountCash   : Number(0)
          currentDiscountPercent: Number(0)
      Session.set('allowAllOrderDetail', true) unless Session.get('allowAllOrderDetail')

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
      if customer = Schema.customers.findOne(e.added._id)
        option =
          contactName: null
          contactPhone: null
          deliveryAddress: null
          deliveryDate: null
          comment: null

        if Session.get('currentOrder')?.paymentsDelivery == 1
          option.contactName     = customer.name ? null
          option.contactPhone    = customer.phone ? null
          option.deliveryAddress = customer.address ? null
        option.buyer = customer._id
        option.tabDisplay = Sky.helpers.respectName(customer.name, customer.gender)
      else
        console.log 'Sai customer'; return
      Schema.orders.update(Session.get('currentOrder')._id, {$set: option})
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
    changeAction: (e) -> Schema.orders.update(Session.get('currentOrder')._id, {$set: {seller: e.added._id}})
    reactiveValueGetter: -> Session.get('currentOrder')?.seller

  paymentMethodSelectOption:
    query: (query) -> query.callback
      results: Sky.system.paymentMethods
      text: 'id'
    initSelection: (element, callback) -> callback _.findWhere(Sky.system.paymentMethods, {_id: Session.get('currentOrder')?.paymentMethod})
    formatSelection: formatPaymentMethodSearch
    formatResult: formatPaymentMethodSearch
    placeholder: 'CHỌN SẢN PTGD'
    minimumResultsForSearch: -1
    changeAction: (e) ->
      if e.added._id == 0
        option =
          paymentMethod  : e.added._id
          currentDeposit : Session.get('currentOrder').finalPrice
          deposit        : Session.get('currentOrder').finalPrice
          debit          : 0
      if e.added._id == 1
        option =
          paymentMethod  : e.added._id
          currentDeposit : 0
          deposit        : 0
          debit          : Session.get('currentOrder').finalPrice
      Schema.orders.update(Session.get('currentOrder')._id, {$set: option})
    reactiveValueGetter: -> _.findWhere(Sky.system.paymentMethods, {_id: Session.get('currentOrder')?.paymentMethod})

  paymentsDeliverySelectOption:
    query: (query) -> query.callback
      results: Sky.system.paymentsDeliveries
      text: 'id'
    initSelection: (element, callback) -> callback _.findWhere(Sky.system.paymentsDeliveries, {_id: Session.get('currentOrder')?.paymentsDelivery})
    formatSelection: formatPaymentMethodSearch
    formatResult: formatPaymentMethodSearch
    placeholder: 'CHỌN SẢN PTGD'
    minimumResultsForSearch: -1
    changeAction: (e) ->
      option =
        paymentsDelivery: e.added._id
      if e.added._id == 1
        if customer = Schema.customers.findOne(Session.get('currentOrder').buyer)
          option.contactName     = customer.name ? null
          option.contactPhone    = customer.phone ? null
          option.deliveryAddress = customer.address ? null
          option.comment         = 'Giao trong ngày'
          option.deliveryDate    = new Date

          $("[name=deliveryDate]").datepicker('setDate', option.deliveryDate)
        else
          console.log 'Sai customer'; return
      Schema.orders.update(Session.get('currentOrder')._id, {$set: option})
    reactiveValueGetter: -> _.findWhere(Sky.system.paymentsDeliveries, {_id: Session.get('currentOrder')?.paymentsDelivery})

  billDiscountSelectOption:
    query: (query) -> query.callback
      results: Sky.system.billDiscounts
      text: 'id'
    initSelection: (element, callback) -> callback _.findWhere(Sky.system.billDiscounts, {_id: Session.get('currentOrder')?.billDiscount})
    formatSelection: formatPaymentMethodSearch
    formatResult: formatPaymentMethodSearch
    placeholder: 'CHỌN SẢN PTGD'
    minimumResultsForSearch: -1
    changeAction: (e) ->
      order = Order.findOne(Session.get('currentOrder')._id)
      option = {billDiscount: e.added._id}
      option.discountCash = 0 if option.billDiscount
      option.discountPercent = 0 if option.billDiscount
      Schema.orders.update(Session.get('currentOrder')._id, {$set: option})
      Sky.global.reCalculateOrder(Session.get('currentOrder')._id)

    reactiveValueGetter: -> _.findWhere(Sky.system.billDiscounts, {_id: Session.get('currentOrder')?.billDiscount})

  qualityOptions:
    reactiveSetter: (val) ->
      option = {}
      option.currentQuality = val
      if val > 0 && Session.get('currentOrder').currentPrice > 0
        option.currentDiscountPercent = Math.round(Session.get('currentOrder').currentDiscountCash/(val * Session.get('currentOrder').currentPrice)*100)
      else
        option.currentDiscountCash    = 0
        option.currentDiscountPercent = 0

      Schema.orders.update(Session.get('currentOrder')._id, {$set: option}) if Session.get('currentOrder')
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
      option = {}
      option.currentDiscountCash = val
      if val > 0
        option.currentDiscountPercent = Math.round(val/(Session.get('currentOrder').currentQuality * Session.get('currentOrder').currentPrice)*100)
      else
        option.currentDiscountPercent = 0

      Schema.orders.update(Session.get('currentOrder')._id, {$set: option}) if Session.get('currentOrder')
    reactiveValue: -> Session.get('currentOrder')?.currentDiscountCash ? 0
    reactiveMax: ->  Session.get('currentProductMaxTotalPrice') ? 0
    reactiveMin: -> 0
    reactiveStep: -> 1000
    others:
      forcestepdivisibility: 'none'

  discountPercentOptions:
    reactiveSetter: (val) ->
      option = {}
      option.currentDiscountPercent = val
      if val > 0
        option.currentDiscountCash = Math.round((Session.get('currentOrder').currentQuality * Session.get('currentOrder').currentPrice)/100*val)
      else
        option.currentDiscountCash = 0

      Schema.orders.update(Session.get('currentOrder')._id, {$set: option}) if Session.get('currentOrder')
    reactiveValue: -> Session.get('currentOrder')?.currentDiscountPercent ? 0
    reactiveMax: -> 100
    reactiveMin: -> 0
    reactiveStep: -> 1

  depositOptions:
    reactiveSetter: (val) ->
      if val >= Session.get('currentOrder').finalPrice
        option=
          currentDeposit  : val
          paymentMethod   : 0
          deposit         : Session.get('currentOrder').finalPrice
          debit           : 0

        Schema.orders.update(Session.get('currentOrder')._id, {$set: option}) if Session.get('currentOrder')
      else
        option=
          currentDeposit  : val
          paymentMethod   : 1
          deposit         : val
          debit           : Session.get('currentOrder').finalPrice - val
        Schema.orders.update(Session.get('currentOrder')._id, {$set: option}) if Session.get('currentOrder')
    reactiveValue: -> Session.get('currentOrder')?.currentDeposit ? 0
    reactiveMax: -> 99999999999
    reactiveMin: -> 0
    reactiveStep: -> 1000
    others:
      forcestepdivisibility: 'none'

  billCashDiscountOptions:
    reactiveSetter: (val)->
      if Session.get('currentOrder')?.billDiscount
        option = {}
        option.discountCash = val
        if val > 0
          if val == Session.get('currentOrder').totalPrice
            option.discountPercent = 100
          else
            option.discountPercent = val*100/Session.get('currentOrder').totalPrice
        else
          option.discountPercent = 0
        option.finalPrice = Session.get('currentOrder').totalPrice - option.discountCash
      Schema.orders.update(Session.get('currentOrder')._id, {$set: option}) if Session.get('currentOrder')
    reactiveValue: -> Session.get('currentOrder')?.discountCash ? 0
    reactiveMax: ->
      if Session.get('currentOrder')?.billDiscount
        Session.get('currentOrder')?.totalPrice ? 0
      else
        Session.get('currentOrder')?.discountCash ? 0
    reactiveMin: ->
      if Session.get('currentOrder')?.billDiscount
        0
      else
        Session.get('currentOrder')?.discountCash ? 0
    reactiveStep: -> 1000
    others:
      forcestepdivisibility: 'none'

  billPercentDiscountOptions:
    reactiveSetter: (val)->
      if Session.get('currentOrder')?.billDiscount
        option = {}
        option.discountPercent = val
        if val > 0
          if val == 100
            option.discountCash = Session.get('currentOrder').totalPrice
          else
            option.discountCash = Math.round(Session.get('currentOrder').totalPrice*option.discountPercent/100)
        else
          option.discountCash = 0
        option.finalPrice = Session.get('currentOrder').totalPrice - option.discountCash
      Schema.orders.update(Session.get('currentOrder')._id, {$set: option}) if Session.get('currentOrder')
    reactiveValue: -> Math.round(Session.get('currentOrder')?.discountPercent*100)/100 ? 0
    reactiveMax: ->
      if Session.get('currentOrder')?.billDiscount
        100
      else
        Session.get('currentOrder')?.discountPercent ? 0
    reactiveMin: ->
      if Session.get('currentOrder')?.billDiscount
        0
      else
        Session.get('currentOrder')?.discountPercent ? 0
    reactiveStep: -> 1
    others:
      forcestepdivisibility: 'none'
      decimals: 2






