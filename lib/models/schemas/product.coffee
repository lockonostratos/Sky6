Schema2.products = new SimpleSchema
  merchant:
    type: String

  warehouse:
    type: String

  creator:
    type: String

  name:
    type: String

  image:
    type: String
    optional: true

  groups:
    type: [String]
    optional: true

  productCode:
    type: String

  skulls:
    type: [String]

  childProduct:
    type: Schema.ChildProduct
    optional: true

  alertQuality:
    type: Number
    defaultValue: 0

  totalQuality:
    type: Number
    defaultValue: 0

  availableQuality:
    type: Number
    defaultValue: 0

  inStockQuality:
    type: Number
    defaultValue: 0

  price:
    type: Number
    defaultValue: 0

  version: { type: Schema.Version }

  provider:
    type: String
    optional: true

  importPrice:
    type: Number
    optional: true

