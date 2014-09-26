Schema.add 'sales', class Sale
  @newByOrder: (order)->
    option =
      merchant     : order.merchant
      warehouse    : order.warehouse
      creator      : order.creator
      seller       : order.seller
      buyer        : order.buyer
      orderCode    : order.orderCode
      productCount : order.productCount
      saleCount    : order.saleCount
      return       : false
      returnCount  : 0
      returnQuality: 0
      deliveryType : order.deliveryType
      paymentMethod: order.paymentMethod
      billDiscount : order.billDiscount
      discountCash : order.discountCash
      totalPrice   : order.totalPrice
      finalPrice   : order.finalPrice
      deposit      : order.deposit
      debit        : order.debit
      status       : false
      success      : false
      paymentsDelivery :0
    option

  @destroy: (saleId) ->
    Schema.saleDetails
    @schema.remove(saleId)