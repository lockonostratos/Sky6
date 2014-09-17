#cập nhật số lượng bán OrderDetail khi tạo mới Orderdetail trùng lắp
reUpdateOrderDetail = (newOrderDetail, oldOrderdetail) ->
  quality      = oldOrderdetail.quality + newOrderDetail.quality
  totalPrice   = quality * oldOrderdetail.price
  discountCash = Math.round(totalPrice * oldOrderdetail.discountPercent/100)
  finalPrice   = totalPrice - discountCash
  Schema.orderDetails.update oldOrderdetail._id,
    $set:
      quality      : quality
      discountCash : discountCash
      finalPrice   : finalPrice
      totalPrice   : totalPrice
  , (error, result) -> console.log result; console.log error if error

#cập nhật Order khi thêm mới OrderDetail
Sky.global.reCalculateOrder = (order_id)->
  order = Schema.orders.findOne(order_id)
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
    if order.currentDeposit > option.finalPrice
      option.paymentMethod = 0
      option.deposit = option.finalPrice
      option.debit = 0
    else
      option.paymentMethod = 1
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
    Schema.orders.update order._id, $set: option


#-------------------Sale------------------------------------
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
createSaleAndSaleOrder= (order, currentOrderDetails)->
  delete order.data._id
  delete order.data.currentProduct
  delete order.data.status
  delete order.data.version
  order.data.return = false
  order.data.status = false
  sale = Schema.sales.insert order.data #  , (e, r) -> console.log currentOrder
  currentSale = Schema.sales.findOne(sale)

  for currentOrderDetail in currentOrderDetails
    productDetails = Schema.productDetails.find({product: currentOrderDetail.product}).fetch()
    subtractQualityOnSales(productDetails, currentOrderDetail, currentSale)
  if currentSale.deliveryType == 1
    Schema.deliveries.findOne({sale: currentSale._id})
  else
    Schema.sales.update sale, $set: {status: true}
  #remove Order and OrderDetail
  Schema.orders.remove order.id
  for detail in currentOrderDetails
    Schema.orderDetails.remove detail._id
subtractQualityOnSales= (stockingItems, sellingItem , currentSale) ->
  transactionedQuality = 0
  for product in stockingItems
    requiredQuality = sellingItem.quality - transactionedQuality
    if product.availableQuality > requiredQuality
      takkenQuality = requiredQuality
    else
      takkenQuality = product.availableQuality
    if currentSale.billDiscount
      totalPrice = (takkenQuality * sellingItem.price)
      if currentSale.discountCash == 0
        discountPercent = 0
      else
        discountPercent = sale.discountCash/(currentSale.totalPrice/100)
      discountCash = (discountPercent * totalPrice)/100
      Schema.saleDetails.insert
        sale: currentSale._id
        product: sellingItem.product
        productDetail: product._id
        quality: takkenQuality
        price: sellingItem.price
        discountCash: discountCash
        discountPercent: discountPercent
        finalPrice: totalPrice - discountCash
    else
      totalPrice = (takkenQuality * sellingItem.price)
      discountCash = (sellingItem.discountPercent * totalPrice)/100
      Schema.saleDetails.insert
        sale: currentSale._id
        product: sellingItem.product
        productDetail: product._id
        quality: takkenQuality
        price: sellingItem.price
        discountCash: discountCash
        discountPercent: sellingItem.discountPercent
        finalPrice: totalPrice - discountCash

    if currentSale.deliveryType == 0 then instockQuality = takkenQuality else instockQuality = 0
    Schema.productDetails.update product._id,
      $inc:
        availableQuality: -takkenQuality
        instockQuality: -instockQuality

    Schema.products.update product.product,
      $inc:
        availableQuality: -takkenQuality
        instockQuality  : -instockQuality

    transactionedQuality += takkenQuality
    if transactionedQuality == sellingItem.quality then break
  return transactionedQuality == sellingItem.quality

Schema.add 'orders', class Order

  addOrderDetail: (product, orderDetails) ->
    orderDetail =
      order           : @id
      product         : @data.currentProduct
      name            : product.name
      skulls          : product.skulls
      quality         : @data.currentQuality
      price           : @data.currentPrice
      discountCash    : @data.currentDiscount
      discountPercent : @data.currentDiscount/(@data.currentQuality * @data.currentPrice)*100
      totalPrice      : @data.currentQuality * @data.currentPrice
      finalPrice      : @data.currentQuality * @data.currentPrice - @data.currentDiscount

      styles          : Sky.helpers.randomColor()

    findProduct =_.findWhere(orderDetails, {product: @data.currentProduct})
    findOrderDetail =_.findWhere(orderDetails,{
      product         : orderDetail.product
      price           : orderDetail.price
      discountPercent : orderDetail.discountPercent
    })
    if findOrderDetail
      reUpdateOrderDetail(orderDetail, findOrderDetail)
    else
      Schema.orderDetails.insert orderDetail, (error, result) -> console.log result; console.log error if error
    Sky.global.reCalculateOrder(@id)

  addNewOrderDetail: (option) ->
    order = this
    newOrderDetail = checkNewOrderDetail(order, option)
    if newOrderDetail.error then return newOrderDetail.message

    orderDetails = checkOrderDetails(order, newOrderDetail.option)

    availableQuality = checkAvailableQualityProduct(order, newOrderDetail.option)
    if availableQuality.error then return availableQuality.message


    saleQuality = checkSaleQualityProduct(availableQuality.product, newOrderDetail.option, orderDetails.findOrderDetail)
    if saleQuality.error then return saleQuality.message

    if orderDetails.findOrderDetail
      reUpdateOrderDetail(saleQuality.newOrderDetail, orderDetails.findProduct)
    else
      Schema.orderDetails.insert saleQuality.newOrderDetail, (error, result) -> console.log result; console.log error if error
    updateOrderWhenAddOrderDetail(saleQuality.newOrderDetail, orderDetails.findProduct)

  addDelivery: (option) ->
    option.merchant = @data.merchant
    option.warehouse = @data.warehouses
    option.creator = @data.creator
    Schema.deliveries.insert option, (error, result) -> console.log result; console.log error if error

  finishOrder: ()->
    order = this
    return 'Order Không Tồn Tại' if !Schema.orders.findOne(order.id)
    orderDetails = Schema.orderDetails.find({order: order.id}).fetch()
    return 'Order Không Có Dữ Liệu' if orderDetails == []
    product_ids = _.union(_.pluck(orderDetails, 'product'))
    products = Schema.products.find({_id: {$in: product_ids}}).fetch()

    result = checkProductInstockQuality(orderDetails, products)
    if result.error then console.log result.error; return
    createSaleAndSaleOrder(order, orderDetails)

#---------------------------------------------------------------------------------------------------------------------->
#Kiểm tra trường giá trị phải chính xác
checkNewOrderDetail = (order, option) ->
  return {error: true, message: "Lỗi, undefined orderDetail"} if !option
  return {error: true, message: "Lỗi, undefined product"} if !option.product
  return {error: true, message: "Lỗi, undefined price"} if !option.price
  return {error: true, message: "Lỗi, undefined quality"} if !option.quality

  return {error: true, message: "Lỗi, Mã Sản Phẩm Không Đúng"} if option.product.length != 17
  return {error: true, message: "Lỗi, Giá Bán Phải Là Số"} if option.price.length >= 0
  return {error: true, message: "Lỗi, Giá Bán Lớn Hơn 0"} if option.price < 0
  return {error: true, message: "Lỗi, Số Lượng  Phải Là Số"} if option.quality.length >= 0
  return {error: true, message: "Lỗi, Số Lượng Sản Phẩm Bán Lớn Hơn 0"} if option.quality < 0

  option.order = order.id
  option.totalPrice      = option.price * option.quality
  if option.discountCash
    return {error: true, message: "Lỗi, Giảm Giá Phải Là Số"} if option.discountCash.length >= 0
    return {error: true, message: "Lỗi, Giảm Giá Lớn Hơn 0"} if option.discountCash < 0
    return {error: true, message: "Lỗi, Giám Giá Đã Vượt Qua Giá Bán"} if option.discountCash > (option.price * option.quality)

    option.discountPercent = option.discountCash/(option.totalPrice/100)
  else
    option.discountCash = 0
    option.discountPercent = 0

  option.finalPrice = option.totalPrice - option.discountCash
  return {error: false, message: "OK", option: option}
#--------------Order--------------------------------------
#Kiểm tra tạo mới Orderdetail có trùng lắp với mãng Orderdetails đã tạo trước đó
checkOrderDetails = (order, newOrderDetail)->
  orderDetails = Schema.orderDetails.find({order: order.id}).fetch()
  findProduct =_.findWhere(orderDetails, {product: newOrderDetail.product})
  findOrderDetail =_.findWhere(orderDetails,{
    product         : newOrderDetail.product
    price           : newOrderDetail.price
    discountPercent : newOrderDetail.discountPercent
  })
  return {findOrderDetail: findOrderDetail, findProduct: findProduct}

#Kiểm tra Product có tồn tại, còn hàng hay ko
checkAvailableQualityProduct = (order, option) ->
  product = Schema.products.findOne({_id: option.product, merchant: order.data.merchant, warehouse: order.data.warehouse})
  if product
    if product.availableQuality < 0
      return {error: true, message: "Lỗi, Sản Phẩm Đã Hết Hàng"}
    else
      option.name = product.name
      option.skulls = product.skulls
      return {error: false, product: product, newOrderDetail: option, message: "OK, Sản Phẩm Còn Hàng"}
  else
    return {error: true, message: "Lỗi, Sản Phẩm Không Tồn Tại"}

#Kiểm tra số lượng còn lại có thể bán
checkSaleQualityProduct = (product, newOrderDetail, oldOrderDetail) ->
  if oldOrderDetail
    if product.availableQuality < (newOrderDetail.quality + oldOrderDetail.quality)
      quality = product.availableQuality - oldOrderDetail.quality
      return {error: true, message: "Lỗi, Số Lượng Mua Phải Nhỏ Hơn #{quality}"}
    else
      return {error: false, message: "Kho Có Đủ Hàng Để Bán"}
  else
    return {error: false, message: "Kho Có Hàng Để Bán"} if product.availableQuality == 0
    if product.availableQuality < newOrderDetail.quality
      return {error: true, message: "Lỗi, Số Lượng Mua Phải Nhỏ Hơn #{product.availableQuality}"}
    else
      return {error: false, message: "Kho Có Đủ Hàng Để Bán"}
#----------------------------------------------------------------------------



