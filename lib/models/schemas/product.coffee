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

  totalQuality:
    type: Number

  availableQuality:
    type: Number

  instockQuality:
    type: Number

  price:
    type: Number

  version: { type: Schema.Version }

  provider:
    type: String
    optional: true

  importPrice:
    type: Number
    optional: true

