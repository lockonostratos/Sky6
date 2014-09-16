Schema.add 'sales', class Sale
  addReturnDetail:  (option, saleDetail, returnDetails, returns = null) ->
    if !returns
      returns =
        merchant       : @data.merchant
        warehouse      : @data.warehouse
        creator        : Meteor.userId()
        returnCode     : "ramdom"
        productSale    : 0
        productQuality : 0
        totalPrice     : 0
        status         : 0
      returns._id = Schema.returns.insert returns

    returnDetail =
      returns       : returns._id
      product       : saleDetail.product
      productDetail : saleDetail.productDetail
      returnQuality : option.returnQuality
      price         : saleDetail.price
      submit        : false
    returnDetail.discountCash = returnDetail.price * returnDetail.returnQuality * saleDetail.discountPercent
    returnDetail.finalPrice = returnDetail.price * returnDetail.returnQuality - saleDetail.discountCash

    Schema.returnDetails.insert returnDetail
    Schema.returns.update returns._id, $inc: {}
