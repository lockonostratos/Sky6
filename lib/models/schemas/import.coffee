Schema2.imports = new SimpleSchema
  creator:
    type: String

  merchant:
    type: String

  warehouse:
    type: String

  description:
    type: String

  finish:
    type: Boolean

  systemTransaction:
    type: String
    optional: true
#----------------------------------
  currentProduct:
    type: String
    optional: true

  currentProvider:
    type: String
    optional: true

  currentQuality:
    type: String
    optional: true

  currentPrice:
    type: String
    optional: true

  currentExpire:
    type: Date
    optional: true
#----------------------------------

  version: { type: Schema.Version }

