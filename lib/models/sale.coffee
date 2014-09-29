Schema.add 'sales', class Sale
  @newByOrder: (order)->
    option =
      merchant          : order.merchant
      warehouse         : order.warehouse
      creator           : order.creator
      seller            : order.seller
      buyer             : order.buyer
      orderCode         : order.orderCode
      productCount      : order.productCount
      saleCount         : order.saleCount
      return            : false
      returnCount       : 0
      returnQuality     : 0
      paymentMethod     : order.paymentMethod
      paymentsDelivery  : order.paymentsDelivery
      billDiscount      : order.billDiscount
      discountCash      : order.discountCash
      totalPrice        : order.totalPrice
      finalPrice        : order.finalPrice
      deposit           : order.deposit
      debit             : order.debit
      status            : false
      success           : false



    option

  @destroy: (saleId) ->
    Schema.saleDetails
    @schema.remove(saleId)

  createSaleExport: ->
    if @data.paymentsDelivery == 0 and @data.status == true and @data.success == false
      saleDetail = Schema.saleDetails.find({sale: @id}).fetch()
      for detail in saleDetail
        Schema.saleDetails.update detail._id, $set:{export: true, exportDate: new Date, status: true}
        Schema.productDetails.update detail.productDetail , $inc:{instockQuality: -detail.quality}
        Schema.products.update detail.product,   $inc:{instockQuality: -detail.quality}

        Schema.saleExports.insert SaleExport.new(@data, detail), (error, result) -> console.log error if error
      Schema.sales.update @id, $set:{success: true}
      console.log 'create SaleExport'