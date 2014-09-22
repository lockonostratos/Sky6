Schema2.imports = new SimpleSchema
  creator:
    type: String

  emailCreator:
    type: String
    optional: true

  merchant:
    type: String

  warehouse:
    type: String

  description:
    type: String

  totalPrice:
    type: Number

  deposit:
    type: Number

  debit:
    type: Number

  finish:
    type: Boolean

  submited:
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
    type: Number
    optional: true

  currentPrice:
    type: Number
    optional: true

  currentExpire:
    type: Date
    optional: true
#----------------------------------

  version: { type: Schema.Version }

