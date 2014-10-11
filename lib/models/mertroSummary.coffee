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


Schema.add 'metroSummaries', class MetroSummary
  @newByMerchant: (merchantId)->
    currentMerchant = Schema.merchants.findOne(merchantId)
    if currentMerchant
      merchant       = currentMerchant._id
      parentMerchant = currentMerchant.parent ? currentMerchant._id
      staffCount       = Schema.userProfiles.find({currentMerchant: merchant})
      staffCountAll    = Schema.userProfiles.find({parentMerchant: parentMerchant})
      customerCount    = Schema.customers.find({currentMerchant: merchant})
      customerCountAll = Schema.customers.find({parentMerchant: parentMerchant})
      merchantCount    = Schema.merchants.find({$or:[{_id: parentMerchant }, {parent: parentMerchant}]})
      warehouseCountAll= Schema.warehouses.find({$or:[{merchant: parentMerchant }, {parentMerchant: parentMerchant}]})
      warehouseCount   = Schema.warehouses.find({merchant: merchant })

      option =
        parentMerchant        : parentMerchant
        merchant              : merchant
        customerCountAll      : customerCountAll.count()
        customerCount         : customerCount.count()
        staffCountAll         : staffCountAll.count()
        staffCount            : staffCount.count()
        merchantCount         : merchantCount.count()
        warehouseCount        : warehouseCount.count()
        warehouseCountAll     : warehouseCountAll.count()
        productCount          : 0
        stockProductCount     : 0
        availableProductCount : 0
        importCount           : 0
        importProductCount    : 0
        saleCount             : 0
        saleProductCount      : 0
        deliveryCount         : 0
        deliveryProductCount  : 0
        inventoryCount        : 0
        inventoryProductCount : 0
        returnCount           : 0
        returnProductCount    : 0
        returnCash            : 0
        saleDepositCash       : 0
        saleDebitCash         : 0
        saleRevenueCash       : 0
        importDepositCash     : 0
        importDebitCash       : 0
        importRevenueCash     : 0

  updateMetroSummary: ->
    merchantCount    = Schema.merchants.find({$or:[{_id: @data.parentMerchant }, {parent: @data.parentMerchant}]})
    warehouseCountAll= Schema.warehouses.find({$or:[{merchant: @data.parentMerchant }, {parentMerchant: @data.parentMerchant}]})
    warehouseCount   = Schema.warehouses.find({merchant: @data.merchant})
    staffCount       = Schema.userProfiles.find({currentMerchant: @data.merchant})
    staffCountAll    = Schema.userProfiles.find({parentMerchant: @data.parentMerchant})
    customerCount    = Schema.customers.find({currentMerchant: @data.merchant})
    customerCountAll = Schema.customers.find({parentMerchant: @data.parentMerchant})

    products         = Schema.products.find({merchant: @data.merchant })
    importCount      = Schema.imports.find({finish: true, merchant: @data.merchant})
    saleCount        = Schema.sales.find({merchant: @data.merchant })
    deliveryCount    = Schema.deliveries.find({merchant: @data.merchant})
    inventoryCount   = Schema.inventories.find({success: true, merchant: @data.merchant})
    returnCount      = Schema.returns.find({merchant: @data.merchant, status: 2})
    transactionCount = Schema.transactions.find({merchant: @data.merchant})

    stockProductCount = 0; availableProductCount = 0
    for item in products.fetch()
      stockProductCount += item.instockQuality
      availableProductCount += item.availableQuality

    inventoryProductCount = 0
    for inventory in inventoryCount.fetch()
      for detail in Schema.inventoryDetails.find({inventory: inventory._id}).fetch()
        inventoryProductCount+= detail.lostQuality

    saleProductCount = 0
    for item in saleCount.fetch()
      saleProductCount+= item.saleCount

    importProductCount = 0
    for imports in importCount.fetch()
      for detail in Schema.importDetails.find({import: imports._id}).fetch()
        importProductCount+= detail.importQuality

    deliveryProductCount = 0
    for delivery in deliveryCount.fetch()
      for detail in Schema.saleDetails.find({sale: delivery.sale}).fetch()
        deliveryProductCount += detail.quality

    returnProductCount = 0
    for returns in returnCount.fetch()
      for detail in Schema.returnDetails.find({return: returns._id}).fetch()
        returnProductCount += detail.returnQuality

    returnCash = 0
    for item in returnCount.fetch()
      returnCash += item.totalPrice

    saleDepositCash   = 0; saleDebitCash   = 0; saleRevenueCash = 0
    importDepositCash = 0; importDebitCash = 0; importRevenueCash = 0
    for item in transactionCount.fetch()
      if item.group is 'sale'
        saleDepositCash += item.depositCash
        saleDebitCash   += item.debitCash
        saleRevenueCash += item.totalCash
      if item.group is 'import'
        importDepositCash += item.depositCash
        importDebitCash   += item.debitCash
        importRevenueCash += item.totalCash

    option =
      customerCountAll      : customerCountAll.count()
      customerCount         : customerCount.count()
      staffCountAll         : staffCountAll.count()
      staffCount            : staffCount.count()
      merchantCount         : merchantCount.count()
      warehouseCount        : warehouseCount.count()
      warehouseCountAll     : warehouseCountAll.count()
      productCount          : products.count()
      stockProductCount     : stockProductCount
      availableProductCount : availableProductCount
      importCount           : importCount.count()
      importProductCount    : importProductCount
      saleCount             : saleCount.count()
      saleProductCount      : saleProductCount
      deliveryCount         : deliveryCount.count()
      deliveryProductCount  : deliveryProductCount
      inventoryCount        : inventoryCount.count()
      inventoryProductCount : inventoryProductCount
      returnCount           : returnCount.count()
      returnProductCount    : returnProductCount

      returnCash            : returnCash
      saleDepositCash       : saleDepositCash
      saleDebitCash         : saleDebitCash
      saleRevenueCash       : saleRevenueCash
      importDepositCash     : importDepositCash
      importDebitCash       : importDebitCash
      importRevenueCash     : importRevenueCash

    console.log option
    Schema.metroSummaries.update @id, $set: option


  @updateMetroSummaryBySale: (saleId)->
    sale = Schema.sales.findOne(saleId)
    if sale
      setOption = {}
      incOption =
        saleCount: 1
        saleProductCount: sale.saleCount
        availableProductCount: -sale.saleCount
        saleDepositCash: sale.deposit
        saleDebitCash: sale.debit
        saleRevenueCash: sale.totalPrice
      incOption.stockProductCount = -sale.saleCount if sale.success == true

      if sale.paymentMethod is 1
        incOption.deliveryCount = 1
        incOption.deliveryProductCount = sale.saleCount

  #    oldSale =Schema.sales.findOne({$and: [
  #      {merchant: sale.merchant}
  #      {'version.createdAt': {$lt: sale.version.updateAt}}
  #    ]}, Sky.helpers.defaultSort(1))
  #    unless oldSale
  #      oldSale = {version: {}}
  #      oldSale.version.createdAt = sale.version.updateAt
  #      if sale.version.updateAt.getDate() == oldSale.version.createdAt.getDate()
  #        incOption.saleCountDay = 1
  #        incOption.saleProductCategoryCountDay = 1
  #        incOption.saleProductCountDay= sale.saleCount
  #        incOption.depositCountDay= sale.deposit
  #        incOption.debitCountDay= sale.debit
  #        incOption.revenueDay= sale.deposit
  #        if sale.paymentMethod is 1
  #          incOption.deliveryCountDay = 1
  #          incOption.deliveryProductCategoryCountDay = 1
  #          incOption.deliveryProductCountDay = sale.saleCount
  #      else
  #        setOption.saleCountDay = 1
  #        setOption.saleProductCategoryCountDay= 1
  #        setOption.saleProductCountDay= sale.saleCount
  #        setOption.depositCountDay= sale.deposit
  #        setOption.debitCountDay= sale.debit
  #        setOption.revenueDay= sale.deposit
  #        if sale.paymentMethod is 1
  #          setOption.deliveryCountDay = 1
  #          setOption.deliveryProductCategoryCountDay= 1
  #          setOption.deliveryProductCountDay = sale.saleCount
  #
  #
  #      if sale.version.updateAt.getMonth() == oldSale.version.createdAt.getMonth()
  #        incOption.saleCountMonth= 1
  #        incOption.saleProductCategoryCountMonth= 1
  #        incOption.saleProductCountMonth= sale.saleCount
  #        incOption.depositCountMonth= sale.deposit
  #        incOption.debitCountMonth= sale.debit
  #        incOption.revenueMonth= sale.deposit
  #        if sale.paymentMethod is 1
  #          incOption.deliveryCountMonth = 1
  #          incOption.deliveryProductCategoryCountMonth = 1
  #          incOption.deliveryProductCountMonth = sale.saleCount
  #      else
  #        setOption.saleCountMonth= 1
  #        setOption.saleProductCategoryCountMonth= 1
  #        setOption.saleProductCountMonth= sale.saleCount
  #        setOption.depositCountMonth= sale.deposit
  #        setOption.debitCountMonth= sale.debit
  #        setOption.revenueMonth= sale.deposit
  #        if sale.paymentMethod is 1
  #          setOption.deliveryCountMonth = 1
  #          setOption.deliveryProductCategoryCountMonth = 1
  #          setOption.deliveryProductCountMonth = sale.saleCount

      metroSummary = Schema.metroSummaries.findOne({merchant: sale.merchant})
      Schema.metroSummaries.update metroSummary._id, $inc: incOption, $set: setOption

  @updateMetroSummaryByReturn: (returnId, returnQuality)->
    returns = Schema.returns.findOne(returnId)
    if returns
      setOption={}
      option =
        stockProductCount: returns.productQuality
        availableProductCount: returns.productQuality
        returnCount: returns.productQuality
        returnProductCount: returns.productQuality
        returnCash: returns.totalPrice


#      oldReturn = Schema.returns.findOne({$and: [
#        {merchant: returns.merchant}
#        {'version.updateAt': {$lt: returns.version.updateAt}}
#        {status: 2}
#      ]}, Sky.helpers.defaultSort())
#
#      unless oldReturn
#        oldReturn = {version: {}}
#        oldReturn.version.updateAt = sale.version.updateAt
#
#      if returns.version.updateAt.getDate() == oldReturn.version.updateAt.getDate()
#        option.returnCountDay     = returns.productQuality
#        option.returnCashDay = returns.totalPrice
#      else
#        setOption.returnCountDay     = returns.productQuality
#        setOption.returnCashDay = returns.totalPrice
#
#      if returns.version.updateAt.getMonth() == oldReturn.version.updateAt.getMonth()
#        option.returnCountMonth     = returns.productQuality
#        option.returnCashMonth = returns.totalPrice
#      else
#        setOption.returnCountMonth     = returns.productQuality
#        setOption.returnCashMonth = returns.totalPrice

      metroSummary = Schema.metroSummaries.findOne({merchant: returns.merchant})
      Schema.metroSummaries.update metroSummary._id, $inc: option, $set: setOption

  @updateMetroSummaryBySaleExport: (saleId)->
    sale  = Schema.sales.findOne(saleId)
    if sale
      if saleStatusIsExport(sale)
        metroSummary = Schema.metroSummaries.findOne({merchant: sale.merchant})
        Schema.metroSummaries.update metroSummary._id, $inc: {stockProductCount: -sale.saleCount}

  @updateMetroSummaryBySaleImport: (saleId)->
    sale  = Schema.sales.findOne(saleId)
    if sale
      if saleStatusIsExport(sale)
        metroSummary = Schema.metroSummaries.findOne({merchant: sale.merchant})
        Schema.metroSummaries.update metroSummary._id, $inc: {
          stockProductCount: sale.saleCount
          availableProductCount: sale.saleCount
        }