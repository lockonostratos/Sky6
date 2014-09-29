Schema2.productLosts = new SimpleSchema
  merchant:
    type: String

  warehouse:
    type: String

  product:
    type: String

  productDetail:
    type: String

  inventory:
    type: String

  name:
    type: String

  skulls:
    type: [String]

  provider:
    type: String
    optional: true

  lostQuality:
    type: Number

  version: { type: Schema.Version }