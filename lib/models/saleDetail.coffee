Schema.add 'saleDetails', class SaleDetail
  @createSaleDetailByOrder = (currentSale, sellingItem, product, takkenQuality)->
    option =
      sale          : currentSale._id
      product       : sellingItem.product
      productDetail : product._id
      name          : sellingItem.name
      skulls        : sellingItem.skulls
      quality       : takkenQuality
      price         : sellingItem.price
      totalPrice    : (takkenQuality * sellingItem.price)
      returnQuality : 0
      export        : false
      status        : false

    if currentSale.billDiscount
      if currentSale.discountCash == 0
        option.discountPercent = 0
      else
        option.discountPercent = currentSale.discountCash/(currentSale.totalPrice/100)
    else
      option.discountPercent = sellingItem.discountPercent
    option.finalPrice = option.totalPrice * (100 - option.discountPercent)/100
    option.discountCash   = option.totalPrice - option.finalPrice

    option._id = @schema.insert option
    option