Schema.add 'orderDetails', class OrderDetail
  @newByOrder: (product, order)->
    option =
      order           : order._id
      product         : product._id
      name            : product.name
      skulls          : product.skulls
      quality         : order.currentQuality
      price           : order.currentPrice
      discountCash    : order.currentDiscount
      discountPercent : order.currentDiscount/(order.currentQuality * order.currentPrice)*100
      totalPrice      : order.currentQuality * order.currentPrice
      finalPrice      : order.currentQuality * order.currentPrice - order.currentDiscount

      styles          : Sky.helpers.randomColor()
    option