Schema.add 'orders', class Order
  addOrderDetail: (option) ->
    order = this
    newOrderDetail = checkNewOrderDetail(order, option)
    if newOrderDetail.error then return newOrderDetail.message

    availableQualityProduct = checkAvailableQualityProduct(order ,option)
    if availableQualityProduct.error then return availableQualityProduct.message

    orderDetails = checkOrderDetails(order, newOrderDetail)

    saleQualityProduct = checkSaleQualityProduct(availableQualityProduct.product, newOrderDetail, orderDetails.findOrderDetai)
    if saleQualityProduct.error then return saleQualityProduct.message

    if orderDetails.findOrderDetai
      reUpdateOrderDetail(option, orderDetails.findProduct)
    else
      Schema.orderDetails.insert option, (error, result) -> console.log result; console.log error if error
    updateOrderWhenAddOrderDetail(option, orderDetails.findProduct)

  addDelivery: (option) ->
    option.merchant = @data.merchant
    option.warehouse = @data.warehouses
    option.creator = @data.creator
    Schema.deliveries.insert option, (error, result) -> console.log result; console.log error if error

#---------------------------------------------------------------------------------------------------------------------->
#Kiểm tra trường giá trị phải chính xác
checkNewOrderDetail = (order, option) ->
  if option.product == undefined then return {error: true, message: "Lỗi, undefined product"}
  if option.price == undefined then return {error: true, message: "Lỗi, undefined price"}
  if option.quality == undefined then return {error: true, message: "Lỗi, undefined quality"}
  if option.discountCash == undefined and option.discountPercent == undefined then return {error: true, message: "Lỗi, undefined discountCash"}

  if option.price.length >= 0 then return {error: true, message: "Lỗi, Giá Bán Phải Là Số"}
  if option.quality.length >= 0 then return {error: true, message: "Lỗi, Số Lượng  Phải Là Số"}
  if option.discountCash and option.discountCash.length >= 0 then return {error: true, message: "Lỗi, Giảm Giá Phải Là Số"}
  if option.discountPercent and option.discountPercent.length >= 0 then return {error: true, message: "Lỗi, Giảm Giá % Phải Là Số"}

  if option.product.length != 17 then return {error: true, message: "Lỗi, Mã Sản Phẩm Không Đúng"}
  if option.price < 0 then return {error: true, message: "Lỗi, Giá Bán Lớn Hơn 0"}
  if option.quality < 0 then return {error: true, message: "Lỗi, Số Lượng Sản Phẩm Bán Lớn Hơn 0"}
  if option.discountCash
    if option.discountCash < 0 then return {error: true, message: "Lỗi, Giảm Giá Lớn Hơn 0"}
    if option.discountCash > (option.price * option.quality)  then return {error: true, message: "Lỗi, Giám Giá Đã Vượt Qua Giá Bán"}
  else
    if option.discountPercent < 0 || option.discountPercent > 100
      return {error: true, message: "Lỗi, Chỉ Được Giảm Giá Từ 0% đến 100%"}


  option.totalPrice      = option.price * option.quality
  if option.discountCash
    option.discountPercent = option.discountCash/(option.totalPrice/100)
    option.finalPrice      = option.totalPrice - option.discountCash
  else
    option.discountCash   = (option.totalPrice * option.discountPercent)/100
    option.finalPrice     = option.totalPrice - option.discountCash

  option.order = order.id

  return {error: false, message: "OK", option: option}

#Kiểm tra Product có tồn tại, còn hàng hay ko
checkAvailableQualityProduct = (order, option) ->
  product = Schema.products.findOne({_id: option.product, merchant: order.data.merchant, warehouse: order.data.warehouse})
  if product
    if product.availableQuality < 0
      return {error: true, message: "Lỗi, Sản Phẩm Đã Hết Hàng"}
    else
      return {error: false, product: product, message: "OK, Sản Phẩm Còn Hàng"}
  else
    return {error: true, message: "Lỗi, Sản Phẩm Không Tồn Tại"}

#Kiểm tra khi tạo mới Orderdetail có trùng lắp với mãng Orderdetails đã tạo trước đó
checkOrderDetails = (order, newOrderDetail)->
  orderDetails = Schema.orderDetails.find({order: order.id}).fetch()
  findProduct =_.findWhere(orderDetails, {product: newOrderDetail.product})
  findOrderDetai =_.findWhere(orderDetails,{
    product         : newOrderDetail.product
    price           : newOrderDetail.price
    discountPercent : newOrderDetail.discountPercent
  })
  return {findOrderDetai: findOrderDetai, findProduct: findProduct}

#Kiểm tra số lượng còn lại có thể bán
checkSaleQualityProduct = (product, newOrderDetail, oldOrderDetail) ->
  if oldOrderDetail
    if product.availableQuality < (newOrderDetail.quality + oldOrderDetail.quality)
      quality = product.availableQuality - oldOrderDetail.quality
      return {error: true, message: "Lỗi, Số Lượng Mua Phải Nhỏ Hơn #{quality}"}
    else
      return {error: false, message: "Kho Có Đủ Hàng Để Bán"}
  else
    if product.availableQuality < newOrderDetail.quality
      return {error: true, message: "Lỗi, Số Lượng Mua Phải Nhỏ Hơn #{product.availableQuality}"}
    else
      return {error: false, message: "Kho Có Đủ Hàng Để Bán"}

#cập nhật số lượng bán OrderDetail khi tạo mới Orderdetail trùng lắp
reUpdateOrderDetail = (newOrderDetail, oldOrderdetail) ->
  quality      = oldOrderdetail.quality + newOrderDetail.quality
  totalPrice   = quality * oldOrderdetail.price
  discountCash = totalPrice * oldOrderdetail.discountPercent/100
  finalPrice   = totalPrice - discountCash
  Schema.orderDetails.update oldOrderdetail._id,
    $set:
      quality      : quality
      discountCash : discountCash
      finalPrice   : finalPrice
  , (error, result) -> console.log result; console.log error if error

#cập nhật Order khi thêm mới OrderDetail
updateOrderWhenAddOrderDetail = (newOrderDetail, product)->
  if product then productCount = 0 else productCount = 1
  Schema.orders.update Session.get('currentOrder')._id,
    $inc:
      productCount  : productCount
      saleCount     : newOrderDetail.quality
      discountCash  : newOrderDetail.discountCash
      totalPrice    : (newOrderDetail.quality * newOrderDetail.price)
      finalPrice    : (newOrderDetail.quality * newOrderDetail.price - newOrderDetail.discountCash)


