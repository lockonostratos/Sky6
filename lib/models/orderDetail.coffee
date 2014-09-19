Schema.add 'orderDetails', class OrderDetail
  @newByOrder: (product, order)->
    option =
      order           : order._id
      product         : product._id
      name            : product.name
      skulls          : product.skulls
      quality         : order.currentQuality
      price           : order.currentPrice
      discountCash    : order.currentDiscountCash
      discountPercent : order.currentDiscountCash/(order.currentQuality * order.currentPrice)*100
      totalPrice      : order.currentQuality * order.currentPrice
      finalPrice      : order.currentQuality * order.currentPrice - order.currentDiscountCash

      styles          : Sky.helpers.randomColor()
    option