Schema2.productDetails = new SimpleSchema
  import:
    type: String
    optional: true

  merchant:
    type: String
    optional: true

  warehouse:
    type: String
    optional: true

  provider:
    type: String
    optional: true

  product:
    type: String
    optional: true

  name:
    type: String

  skulls:
    type: [String]

  importQuality:
    type: Number
    optional: true

  availableQuality:
    type: Number
    optional: true

  inStockQuality:
    type: Number
    optional: true

  importPrice:
    type: Number
    optional: true

  expire:
    type: Date
    optional: true

  systemTransaction:
    type: String
    optional: true

  checkingInventory:
    type: Boolean

  inventory:
    type: String
    optional: true

  version: { type: Schema.Version }
