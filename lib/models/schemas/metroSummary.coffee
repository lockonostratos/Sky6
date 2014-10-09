Schema2.metroSummaries = new SimpleSchema
  parentMerchant:
    type: String

  merchant:
    type: String

  productCount:
    type: Number

  stockCount:
    type: Number

  deliveryProductCount:
    type: Number

  customerCountAll:
    type: Number

  customerCountMerchant:
    type: Number

  staffCountAll:
    type: Number

  staffCountMerchant:
    type: Number

  deliveryCount:
    type: Number

  saleCount:
    type: Number

  saleCountDay:
    type: Number

  saleCountMonth:
    type: Number

  returnCount:
    type: Number

  returnCountDay:
    type: Number

  returnCountMonth:
    type: Number

  revenue:
    type: Number

  revenueDay:
    type: Number

  revenueMonth:
    type: Number

  version: { type: Schema.Version }

