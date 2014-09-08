Schema2.metroSummaries = new SimpleSchema
  warehouse:
    type: String

  productCount:
    type: Number

  stockCount:
    type: Number

  customerCount:
    type: Number

  staffCount:
    type: Number

  staffCountMerchant:
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

Schema.add 'metroSummaries'
