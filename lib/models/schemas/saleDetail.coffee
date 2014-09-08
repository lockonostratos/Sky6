Schema2.saleDetails = new SimpleSchema
  sale:
    type: String

  product:
    type: String

  productDetail:
    type: String

  quality:
    type: Number

  returnQuality:
    type: String
    optional: true

  price:
    type: Number

  discountCash:
    type: Number
    decimal: true

  discountPercent:
    type: Number
    decimal: true

  finalPrice:
    type: Number



  version: { type: Schema.Version }

Schema.add 'saleDetails'