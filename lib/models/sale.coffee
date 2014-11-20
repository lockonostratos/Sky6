saleStatusIsExport = (sale)->
  if sale.status == sale.received == true and sale.submitted == sale.exported == sale.imported == false and (sale.paymentsDelivery == 0 || sale.paymentsDelivery == 1)
    true
  else
    false

saleStatusIsImport = (sale)->
  if sale.status == sale.received == sale.exported == true and sale.submitted == sale.imported == false and sale.paymentsDelivery == 1
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
      returnLock        : false
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
      imported          : false
      exported          : false
      received          : false
      status            : false
      submitted         : false

  @insertByOrder: (order)->
    @schema.insert Sale.newByOrder(order), (error, result) -> if error then console.log error; null else result

  @destroy: (saleId) ->
    Schema.saleDetails
    @schema.remove(saleId)

  createSaleExport: ->
    if saleStatusIsExport(@data)
      saleDetails = Schema.saleDetails.find({sale: @id}).fetch()
      for detail in saleDetails
        Schema.saleDetails.update detail._id, $set:{exported: true, exportDate: new Date, status: true}
        Schema.productDetails.update detail.productDetail , $inc:{inStockQuality: -detail.quality}
        Schema.products.update detail.product,   $inc:{inStockQuality: -detail.quality}

        Schema.saleExports.insert SaleExport.new(@data, detail), (error, result) -> console.log error if error

      Notification.saleConfirmByExporter(@id)
      MetroSummary.updateMetroSummaryBySaleExport(@id)
      if @data.paymentsDelivery == 0 then  Schema.sales.update @id, $set:{submitted: true, exported: true}
      if @data.paymentsDelivery == 1
        Schema.sales.update @id, $set:{exported: true, status: false}
        Schema.deliveries.update @data.delivery, $set:{status: 3, exporter: Meteor.userId()}
      console.log 'create ExportSale'

    if saleStatusIsImport(@data)
      saleDetails = Schema.saleDetails.find({sale: @id}).fetch()
      for detail in saleDetails
        option =
          availableQuality: detail.quality
          inStockQuality  : detail.quality
        Schema.productDetails.update detail.productDetail, $inc: option
        Schema.products.update detail.product, $inc: option

#        Schema.saleExports.insert SaleExport.new(@data, detail), (error, result) -> console.log error if error
      Notification.saleConfirmImporter(@id)
      MetroSummary.updateMetroSummaryBySaleImport(@id)
      Schema.sales.update @id, $set:{imported: true, status: false}
      Schema.deliveries.update @data.delivery, $set:{status: 9, importer: Meteor.userId()}
      console.log 'create ImportSale'

  #xác nhận đã nhận tiền
  confirmReceiveSale: ->
    if @data.received == @data.imported ==  @data.exported == @data.submitted == false and @data.status == true
      unless Role.hasPermission(Schema.userProfiles.findOne({user: Meteor.userId()})._id, Sky.system.merchantPermissions.cashierSale.key) then return
      option = {received: true}
      if @data.paymentsDelivery == 1
        option.status = false
        Schema.deliveries.update @data.delivery, $set: {status: 1}

      transaction =  Transaction.newBySale(@data)
      transactionDetail = TransactionDetail.newByTransaction(transaction)
      Notification.saleConfirmByAccounting(@id)
      MetroSummary.updateMetroSummaryBySale(@id)
      Schema.sales.update @id, $set: option

    if @data.status == @data.success == @data.received == @data.exported == true and @data.submitted ==  @data.imported == false and @data.paymentsDelivery == 1
      unless Role.hasPermission(Schema.userProfiles.findOne({user: Meteor.userId()})._id, Sky.system.merchantPermissions.cashierDelivery.key) then return
      userProfile = Schema.userProfiles.findOne({user: Meteor.userId()})
      Schema.deliveries.update @data.delivery, $set:{status: 6, cashier: Meteor.userId()}
      transaction = Transaction.findOne({parent: @id, merchant: userProfile.currentMerchant, status: "tracking"})
      debitCash = @data.debit
      transaction.recalculateTransaction(debitCash)
      Notification.saleAccountingConfirmByDelivery(@id)





