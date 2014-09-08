Schema2.returnDetails  = new SimpleSchema
  returns:
    type: String

  product:
    type: String

  productDetail:
    type: String

  returnQuality:
    type: Number

  price:
    type: Number

  discountCash:
    type: Number

  finalPrice:
    type: Number

  submit:
    type: Boolean
    optional: true


  version: { type: Schema.Version }

Schema.add 'returnDetails'