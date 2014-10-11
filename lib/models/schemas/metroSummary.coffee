Schema2.metroSummaries = new SimpleSchema
  parentMerchant:
    type: String

  merchant:
    type: String

  merchantCount:
    type: Number

  warehouseCount:
    type: Number

  warehouseCountAll:
    type: Number

  customerCountAll:
    type: Number

  customerCount:
    type: Number

  staffCountAll:
    type: Number

  staffCount:
    type: Number

  productCount:
    type: Number

  stockProductCount:
    type: Number

  availableProductCount:
    type: Number


  importCount:
    type: Number

  importProductCount:
    type: Number

  saleCount:
    type: Number

  saleProductCount:
    type: Number

  deliveryCount:
    type: Number

  deliveryProductCount:
    type: Number

  returnCount:
    type: Number

  returnProductCount:
    type: Number

  inventoryCount:
    type: Number

  inventoryProductCount:
    type: Number



  returnCash:
    type: Number

  saleDepositCash:
    type: Number

  saleDebitCash:
    type: Number

  saleRevenueCash:
    type: Number

  importDepositCash:
    type: Number

  importDebitCash:
    type: Number

  importRevenueCash:
    type: Number


  version: { type: Schema.Version }

