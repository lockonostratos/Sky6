Schema2.returns = new SimpleSchema
  merchant:
    type: String

  warehouse:
    type: String

  sale:
    type: String

  creator:
    type: String

  creatorName:
    type: String

  submitReturn:
    type: String
    optional: true

  returnCode:
    type: String

  productSale:
    type: Number
    optional: true

  productQuality:
    type: Number

  discountCash:
    type: Number

  discountPercent:
    type: Number
    decimal: true

  totalPrice:
    type: Number

  finallyPrice:
    type: Number

  comment:
    type: String

  status:
    type: Number

  version: { type: Schema.Version }


