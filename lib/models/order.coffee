Schema.add 'orders', class Order

  addNewOrder: (option) ->
    option.merchant     = @data.merchant
    option.warehouse    = @data.merchant
    option.discountCash = 0
    option.productCount = 0
    option.saleCount    = 0
    option.totalPrice   = 0
    option.finalPrice   = 0
    option.deposit      = 0
    option.debit        = 0
    option.status       = 0
    Schema.orders.insert option, (error, result) -> console.log result; console.log error if error

  addOrderDetail: (option) ->
    checkNewOrderDetail = checkNewOrderDetail(option)
    if checkNewOrderDetail.error then return checkNewOrderDetail.message
    checkAvailableQualityProduct = checkAvailableQualityProduct(option)
    if checkAvailableQualityProduct.error then return checkAvailableQualityProduct.message
    checkOrderDetails = checkOrderDetails()
    checkSaleQualityProduct = checkSaleQualityProduct(checkOrderDetails.findOrderDetai, checkNewOrderDetail, checkOrderDetails.findOrderDetai)
    if checkSaleQualityProduct.error then return checkSaleQualityProduct.message
    if checkOrderDetails.findOrderDetai
      reUpdateOrderDetail(option, checkOrderDetails.findProduct)
    else
      Schema.orderDetails.insert option, (error, result) -> console.log result; console.log error if error
    updateOrderWhenAddOrderDetail(option, checkOrderDetails.findProduct)

  addDelivery: (option) ->
    option.merchant = @data.merchant
    option.warehouse = @data.warehouses
    option.creator = @data.creator
    Schema.deliveries.insert option, (error, result) -> console.log result; console.log error if error

#---------------------------------------------------------------------------------------------------------------------->
  #Kiểm tra trường giá trị phải chính xác
  checkNewOrderDetail = (option) ->
    if option.product.length != 17 then return {error: true, message: "Lỗi, Mã Sản Phẩm Không Đúng"}
    if option.price < 0 then return {error: true, message: "Lỗi, Giá Sản Phẩm Bán Lớn Hơn 0"}
    if option.quality < 0 then return {error: true, message: "Lỗi, Số Lượng Sản Phẩm Bán Lớn Hơn 0"}
    if option.discountCash < 0 then return {error: true, message: "Lỗi, Giảm Giá Lớn Hơn 0"}
    if option.discountCash > (option.price * option.quality)  then return {error: true, message: "Lỗi, Giám Giá Đã Vượt Qua Giá Bán"}
    if option.discountPercent < 0 then return {error: true, message: "Lỗi, Giảm Giá % Không Được Nhỏ Hơn 0"}
    if option.discountPercent > 100 then return {error: true, message: "Lỗi, Giảm Giá % Không Được Lớn Hơn 0"}
    if option.tempDiscountPercent < 0 then return {error: true, message: "Lỗi, Giảm Giá % Temp Không Được Nhỏ Hơn 0"}
    if option.tempDiscountPercent > 100 then return {error: true, message: "Lỗi, Giảm Giá % Temp Không Được Lớn Hơn 0"}
    if option.finalPrice < 0 then return {error: true, message: "Lỗi, Tổng Giá Nhỏ Hơn 0"}
    if option.finalPrice > (option.price * option.quality) then return {error: true, message: "Lỗi, Tổng Giá Quá Lớn"}

  #Kiểm tra Product có tồn tại, còn hàng hay ko
  checkAvailableQualityProduct = (option) ->
    product = Schema.product.findOne({id: option.product, merchant: @data.merchant, warehouse: @data.warehouse})
    if product
      if product.availableQuality < 0
        return {error: true, message: "Lỗi, Sản Phẩm Đã Hết Hàng"}
      else
        return {error: false, product: product, message: "OK, Sản Phẩm Còn Hàng"}
    else
      return {error: true, message: "Lỗi, Sản Phẩm Không Tồn Tại"}

  #Kiểm tra khi tạo mới Orderdetail có trùng lắp với mãng Orderdetails đã tạo trước đó
  checkOrderDetails = (newOrderDetail)->
    orderDetails = Schema.orderDetails.find({order: @id}).fetch()
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


