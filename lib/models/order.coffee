subtractQualityOnSales= (stockingItems, sellingItem , currentSale) ->
  transactionedQuality = 0
  for product in stockingItems
    requiredQuality = sellingItem.quality - transactionedQuality
    if product.availableQuality > requiredQuality
      takkenQuality = requiredQuality
    else
      takkenQuality = product.availableQuality

    SaleDetail.createSaleDetailByOrder(currentSale, sellingItem, product, takkenQuality)
    if currentSale.deliveryType == 0 then instockQuality = takkenQuality else instockQuality = 0
    Schema.productDetails.update product._id, $inc:{availableQuality: -takkenQuality, instockQuality: -instockQuality}
    Schema.products.update product.product,   $inc:{availableQuality: -takkenQuality, instockQuality: -instockQuality}

    transactionedQuality += takkenQuality
    if transactionedQuality == sellingItem.quality then break
  return transactionedQuality == sellingItem.quality

createSaleAndSaleOrder= (order, currentOrderDetails)->
  sale = Sale.newByOrder(order)
  sale._id = Schema.sales.insert sale, (error, result) -> console.log error if error
  currentSale = Schema.sales.findOne(sale)
  if currentSale
    for currentOrderDetail in currentOrderDetails
      productDetails = Schema.productDetails.find({product: currentOrderDetail.product}).fetch()
      subtractQualityOnSales(productDetails, currentOrderDetail, currentSale)
    if currentSale.deliveryType == 1
      delivery = Delivery.createdNewBySale(currentSale._id, order._id)
      Schema.sales.update currentSale._id, $set: {delivery: delivery._id}
    else
      Schema.sales.update currentSale._id, $set: {status: true, success: true}

  return currentSale._id if currentSale

reUpdateOrderDetail = (newOrderDetail, oldOrderDetail) ->
  option={}
  option.quality      = oldOrderDetail.quality + newOrderDetail.quality
  option.totalPrice   = option.quality * oldOrderDetail.price
  option.discountCash = Math.round(option.totalPrice * oldOrderDetail.discountPercent/100)
  option.finalPrice   = option.totalPrice - option.discountCash

  Schema.orderDetails.update oldOrderDetail._id, $set: option , (error, result) -> console.log error if error

checkProductInstockQuality= (orderDetailsList, productList)->
  orderDetails = _.chain(orderDetailsList)
  .groupBy("product")
  .map (group, key) ->
    return {
    product: key
    quality: _.reduce(group, ((res, current) -> res + current.quality), 0)
    }
  .value()
  try
    for currentDetail in orderDetails
      currentProduct = _.findWhere(productList, {_id: currentDetail.product})
      if currentProduct.availableQuality < currentDetail.quality
        throw {message: "lỗi", item: currentDetail}

    return {}
  catch e
    return {error: e}

createTransactionAndDetailByOrder = (saleID)->
  sale = Schema.sales.findOne(saleID)
  transaction = Transaction.newBySale(sale)
  transactionDetail = TransactionDetail.newByTransaction(transaction)

removeOrderAndOrderDetailAfterCreateSale= (orderId)->
  allTabs = Schema.orders.find({creator: Meteor.userId()}).fetch()
  currentSource = _.findWhere(allTabs, {_id: orderId})
  currentIndex = allTabs.indexOf(currentSource)
  currentLength = allTabs.length
  if currentLength == 1
    Order.createOrderAndSelect()
    Order.removeAll(orderId)
  if currentLength > 1
    if currentIndex > 0
      UserProfile.update {currentOrder: allTabs[currentIndex-1]._id}
    else
      UserProfile.update {currentOrder: allTabs[currentIndex+1]._id}
    Order.removeAll(orderId)
#-----------------------------------------------------------------------------------------------------------------------
Schema.add 'orders', class Order
  @createOrder: ->
    userProfile = Schema.userProfiles.findOne({user: Meteor.userId()})
    option =
      merchant               : userProfile.currentMerchant
      warehouse              : userProfile.currentWarehouse
      creator                : userProfile.user
      seller                 : userProfile.user
      buyer                  : "null"
      currentProduct         : "null"
      currentQuality         : 0
      currentPrice           : 0
      currentDiscountCash    : 0
      currentDiscountPercent : 0
      orderCode              : 'asdsad'
      deliveryType           : 0
      paymentMethod          : 0
      discountCash           : 0
      discountPercent        : 0
      productCount           : 0
      saleCount              : 0
      totalPrice             : 0
      finalPrice             : 0
      deposit                : 0
      debit                  : 0
      billDiscount           : false
      status                 : 0
      currentDeposit         : 0

    option._id = Schema.orders.insert option
    option

  @createOrderAndSelect: -> UserProfile.update {currentOrder: @createOrder()._id}

  @removeAll: (orderId)->
    try
      order = Schema.orders.findOne(orderId)
      if order
        for orderDetail in Schema.orderDetails.find({order: order._id}).fetch()
          Schema.orderDetails.remove(orderDetail._id)
        Schema.orders.remove(order._id)
      else
        throw {error: true, message: "Không Tìm Thấy Order"}
      return {error: false, message: "Đã Xóa Order"}
    catch e
      return e

  @addDelivery: (option) ->
    option.merchant = @data.merchant
    option.warehouse = @data.warehouses
    option.creator = @data.creator
    Schema.deliveries.insert option, (error, result) -> console.log result; console.log error if error

  @addOrderDetail: (orderId) ->
    order = @schema.findOne(orderId)
    if order
      return console.log 'Chưa chọn sản phẩm' if !product = Schema.products.findOne(order.currentProduct)
      return console.log 'Số lượng phải lớn hơn 0' if order.currentQuality == 0
      return console.log 'Giá sản phẩm phải lớn hơn 0' if order.currentPrice == 0
      return console.log 'Giá sản phẩm phải lớn hơn giá nhập' if order.currentPrice < product.price
      orderDetail = OrderDetail.newByOrder(product, order)
      orderDetails = Schema.orderDetails.find({order: order._id}).fetch()
      findOrderDetail =_.findWhere(orderDetails,{
        product         : orderDetail.product
        price           : orderDetail.price
        discountPercent : orderDetail.discountPercent
      })
      if findOrderDetail
        reUpdateOrderDetail(orderDetail, findOrderDetail)
      else
        Schema.orderDetails.insert orderDetail, (error, result) -> console.log error if error
      Sky.global.reCalculateOrder(order._id)
    else
      return console.log 'Mã phiếu không đúng'

  @finishOrder: (orderId)->
    return 'Order Không Tồn Tại' if !order = Schema.orders.findOne(orderId)
    return 'Chưa chọn người mua' if !buyer = Schema.customers.findOne(order.buyer)
    return 'Order Không Có Dữ Liệu' if (orderDetails = Schema.orderDetails.find({order: order._id}).fetch()).length < 1
    if order.deliveryType == 1
      return 'Thông tin giao hàng chưa đầy đủ (Name)'    if !order.contactName || order.contactName.length < 1
      return 'Thông tin giao hàng chưa đầy đủ (Phone)'   if !order.contactPhone || order.contactPhone.length < 1
      return 'Thông tin giao hàng chưa đầy đủ (Address)' if !order.deliveryAddress || order.deliveryAddress.length < 1
      return 'Thông tin giao hàng chưa đầy đủ (comment)' if !order.comment || order.comment < 1
#      return 'Thông tin giao hàng chưa đầy đủ (deliveryDate)' if order.deliveryDate.length > 1

    product_ids = _.union(_.pluck(orderDetails, 'product'))
    products = Schema.products.find({_id: {$in: product_ids}}).fetch()

    result = checkProductInstockQuality(orderDetails, products)
    if result.error then console.log result.error; return

    saleId = createSaleAndSaleOrder(order, orderDetails)
    removeOrderAndOrderDetailAfterCreateSale(order._id)
    createTransactionAndDetailByOrder(saleId)
    return("Tạo phiếu bán hàng thành công")

#-----------------------------------------------------
Sky.global.reCalculateOrder = (orderId)->
  order = Schema.orders.findOne(orderId)
  orderDetails = Schema.orderDetails.find({order: order._id}).fetch()
  if orderDetails.length > 0
    temp=
      saleCount       :0
      discountCash    :0
      discountPercent :0
      totalPrice      :0
    for detail in orderDetails
      temp.totalPrice += detail.quality * detail.price
      temp.saleCount += detail.quality
      if order.billDiscount
        temp.discountCash = order.discountCash
      else
        temp.discountCash += detail.discountCash
    temp.discountPercent = temp.discountCash/temp.totalPrice*100

    option =
      saleCount       : temp.saleCount
      discountCash    : temp.discountCash
      discountPercent : temp.discountPercent
      totalPrice      : temp.totalPrice
      finalPrice      : temp.totalPrice - temp.discountCash

    if order.paymentMethod == 0
      if order.currentDeposit == order.finalPrice
        option.currentDeposit = option.finalPrice
      else
        option.currentDeposit = order.currentDeposit if order.currentDeposit > option.finalPrice
        option.currentDeposit = option.finalPrice if order.currentDeposit < option.finalPrice

      option.deposit = option.finalPrice
      option.debit = 0
    if order.paymentMethod == 1
      if order.currentDeposit >= option.finalPrice
        option.paymentMethod = 0
        option.deposit = option.finalPrice
        option.debit = 0
      else
        option.deposit = order.currentDeposit
        option.debit = option.finalPrice - order.currentDeposit

    Schema.orders.update order._id, $set: option
  else
    option =
      saleCount       : 0
      discountCash    : 0
      discountPercent : 0
      totalPrice      : 0
      finalPrice      : 0
      paymentMethod   : 0
      currentDeposit  : 0
      deposit         : 0
      debit           : 0
    Schema.orders.update order._id, $set: option

Sky.global.userProfile = -> Schema.userProfiles.findOne({user: Meteor.userId()})



