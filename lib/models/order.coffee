subtractQualityOnSales= (stockingItems, sellingItem , currentSale) ->
  transactionQuality = 0
  for productDetail in stockingItems
    requiredQuality = sellingItem.quality - transactionQuality
    if productDetail.availableQuality > requiredQuality
      takkenQuality = requiredQuality
    else
      takkenQuality = productDetail.availableQuality

    SaleDetail.createSaleDetailByOrder(currentSale, sellingItem, productDetail, takkenQuality)

#    if currentSale.paymentsDelivery == 2 then instockQuality = takkenQuality else instockQuality = 0
#    Schema.productDetails.update productDetail._id, $inc:{availableQuality: -takkenQuality, instockQuality: -instockQuality}
#    Schema.products.update productDetail.product,   $inc:{availableQuality: -takkenQuality, instockQuality: -instockQuality}

    Schema.productDetails.update productDetail._id, $inc:{availableQuality: -takkenQuality}
    Schema.products.update productDetail.product  , $inc:{availableQuality: -takkenQuality}

    transactionQuality += takkenQuality
    if transactionQuality == sellingItem.quality then break
  return transactionQuality == sellingItem.quality

createSaleAndSaleOrder= (order)->
  sale = Schema.sales.insert Sale.newByOrder(order), (error, result) -> console.log error if error
  if currentSale = Schema.sales.findOne(sale)
    for currentOrderDetail in Schema.orderDetails.find({order: order._id}).fetch()
      productDetails = Schema.productDetails.find({product: currentOrderDetail.product}).fetch()
      subtractQualityOnSales(productDetails, currentOrderDetail, currentSale)

    option = {status: true}
    if currentSale.paymentsDelivery == 1
      option.delivery = Schema.deliveries.insert Delivery.newBySale(currentSale._id, order._id)
    Schema.sales.update currentSale._id, $set: option
  return currentSale._id if currentSale

reUpdateOrderDetail = (newOrderDetail, oldOrderDetail) ->
  option={}
  option.quality      = oldOrderDetail.quality + newOrderDetail.quality
  option.totalPrice   = option.quality * oldOrderDetail.price
  option.discountCash = Math.round(option.totalPrice * oldOrderDetail.discountPercent/100)
  option.finalPrice   = option.totalPrice - option.discountCash

  Schema.orderDetails.update oldOrderDetail._id, $set: option , (error, result) -> console.log error if error

checkProductInstockQuality= (orderId)->
  orderDetails = Schema.orderDetails.find({order: orderId}).fetch()
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

createOrderCode= ->
  date = new Date()
  day = new Date(date.getFullYear(), date.getMonth(), date.getDate());
  oldOrder = Schema.orders.findOne({'version.createdAt': {$gt: day}},{sort: {'version.createdAt': -1}})
  if oldOrder
    lenght = oldOrder.orderCode.length
    code = Number(oldOrder.orderCode.substring(lenght-4))+1
    if 99 < code < 999 then code = "0#{code}"
    if 9 < code < 100 then code = "00#{code}"
    if code < 10 then code = "000#{code}"
    orderCode = "#{Sky.helpers.formatDate()}-#{code}"
  else
    orderCode = "#{Sky.helpers.formatDate()}-0001"
  orderCode

removeOrderAndOrderDetailAfterCreateSale= (orderId, userProfile)->
  allTabs = Schema.orders.find({
    _id       : orderId
    creator   : Meteor.userId()
    merchant  : userProfile.currentMerchant
    warehouse : userProfile.currentWarehouse
  }).fetch()
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
    buyer = Schema.customers.findOne({parentMerchant: userProfile.parentMerchant})

    option =
      merchant               : userProfile.currentMerchant
      warehouse              : userProfile.currentWarehouse
      creator                : userProfile.user
      seller                 : userProfile.user
      buyer                  : buyer._id ? 'null'
      currentProduct         : "null"
      currentQuality         : 0
      currentPrice           : 0
      currentDiscountCash    : 0
      currentDiscountPercent : 0
      orderCode              : createOrderCode()
      tabDisplay             : 'New Order'
      paymentsDelivery       : 0
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

    if buyer then option.tabDisplay = Sky.helpers.respectName(buyer.name, buyer.gender)
    option._id = Schema.orders.insert option
    option

  @createOrderAndSelect: -> order = @createOrder(); UserProfile.update {currentOrder: order._id}; order

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
    return 'Bạn Chưa Đăng Nhập' if !userProfile = Schema.userProfiles.findOne({user: Meteor.userId()})
    return 'Order Không Tồn Tại' if !order = Schema.orders.findOne({
      _id       : orderId
      creator   : Meteor.userId()
      merchant  : userProfile.currentMerchant
      warehouse : userProfile.currentWarehouse
    })
    return 'Chưa chọn người mua' if !buyer = Schema.customers.findOne({
      _id           : order.buyer
      parentMerchant: userProfile.parentMerchant
    })
    return 'Order Không Có Dữ Liệu' if !orderDetail = Schema.orderDetails.findOne({order: order._id})

    if order.paymentsDelivery == 1
      return 'Thông tin giao hàng chưa đầy đủ (Name)'    if !order.contactName || order.contactName.length < 1
      return 'Thông tin giao hàng chưa đầy đủ (Phone)'   if !order.contactPhone || order.contactPhone.length < 1
      return 'Thông tin giao hàng chưa đầy đủ (Address)' if !order.deliveryAddress || order.deliveryAddress.length < 1
      return 'Thông tin giao hàng chưa đầy đủ (comment)' if !order.comment || order.comment < 1
#      return 'Thông tin giao hàng chưa đầy đủ (deliveryDate)' if order.deliveryDate.length > 1

    result = checkProductInstockQuality(orderId)
    if result.error then console.log result.error; return

    saleId = createSaleAndSaleOrder(order)
    Notification.newSaleDefault(saleId)

#----Tự động xác nhận đã nhận tiền(Kế Toán)-----
#    Sale.findOne(saleId).confirmReceiveSale()
#----Tự động xuất kho khi đã nhận tiền(Thủ Kho)----
#    Sale.findOne(saleId).createSaleExport()


    removeOrderAndOrderDetailAfterCreateSale(orderId, userProfile)
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



