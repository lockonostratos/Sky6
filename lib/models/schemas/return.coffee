Schema2.returns = new SimpleSchema
  merchant:
    type: String

  warehouse:
    type: String

  sale:
    type: String

  creator:
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

  totalPrice:
    type: Number

  comment:
    type: String

  status:
    type: Number

  version: { type: Schema.Version }


