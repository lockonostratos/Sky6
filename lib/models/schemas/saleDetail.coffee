Schema2.saleDetails = new SimpleSchema
  sale:
    type: String

  product:
    type: String

  productDetail:
    type: String

  name:
    type: String
    optional: true

  skulls:
    type: [String]
    optional: true

  color:
    type: String
    optional: true

  quality:
    type: Number

  returnQuality:
    type: Number
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

  styles:
    type: String
    optional: true



  version: { type: Schema.Version }

