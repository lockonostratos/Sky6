saleStatusIsExport = (sale)->
  if sale.status == true and sale.success == sale.export == sale.import == false and (sale.paymentsDelivery == 0 || sale.paymentsDelivery == 1)
    true
  else
    false

saleStatusIsImport = (sale)->
  if sale.status == sale.export == true and sale.success == sale.import == false and sale.paymentsDelivery == 1
    true
  else
    false


createSaleCode= ->
  date = new Date()
  day = new Date(date.getFullYear(), date.getMonth(), date.getDate());
  oldSale = Schema.sales.findOne({'version.createdAt': {$gt: day}},{sort: {'version.createdAt': -1}})
  if oldSale
    code = Number(oldSale.orderCode.substring(oldSale.orderCode.length-4))+1
    if 99 < code < 999 then code = "0#{code}"
    if 9 < code < 100 then code = "00#{code}"
    if code < 10 then code = "000#{code}"
    orderCode = "#{Sky.helpers.formatDate()}-#{code}"
  else
    orderCode = "#{Sky.helpers.formatDate()}-0001"
  orderCode


Schema.add 'sales', class Sale
  @newByOrder: (order)->
    option =
      merchant          : order.merchant
      warehouse         : order.warehouse
      creator           : order.creator
      seller            : order.seller
      buyer             : order.buyer
      orderCode         : createSaleCode()
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
      import            : false
      export            : false
      status            : false
      success           : false



    option

  @destroy: (saleId) ->
    Schema.saleDetails
    @schema.remove(saleId)

  createSaleExport: ->
    if saleStatusIsExport(@data)
      saleDetails = Schema.saleDetails.find({sale: @id}).fetch()
      for detail in saleDetails
        Schema.saleDetails.update detail._id, $set:{export: true, exportDate: new Date, status: true}
        Schema.productDetails.update detail.productDetail , $inc:{instockQuality: -detail.quality}
        Schema.products.update detail.product,   $inc:{instockQuality: -detail.quality}

        Schema.saleExports.insert SaleExport.new(@data, detail), (error, result) -> console.log error if error
      MetroSummary.updateMetroSummaryBySaleExport(@id)
      if @data.paymentsDelivery == 0 then  Schema.sales.update @id, $set:{success: true, export: true}
      if @data.paymentsDelivery == 1
        Schema.sales.update @id, $set:{export: true, status: false}
        Schema.deliveries.update @data.delivery, $set:{status: 2, exporter: Meteor.userId()}
      console.log 'create ExportSale'

    if saleStatusIsImport(@data)
      saleDetails = Schema.saleDetails.find({sale: @id}).fetch()
      for detail in saleDetails
        option =
          availableQuality: detail.quality
          instockQuality  : detail.quality
        Schema.productDetails.update detail.productDetail, $inc: option
        Schema.products.update detail.product, $inc: option

#        Schema.saleExports.insert SaleExport.new(@data, detail), (error, result) -> console.log error if error
      MetroSummary.updateMetroSummaryBySaleImport(@id)
      Schema.sales.update @id, $set:{import: true, status: false}
      Schema.deliveries.update @data.delivery, $set:{status: 8, importer: Meteor.userId()}
      console.log 'create ImportSale'







