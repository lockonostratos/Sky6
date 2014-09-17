Schema2.returnDetails  = new SimpleSchema
  returns:
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

  styles:
    type: String
    optional: true

  returnQuality:
    type: Number

  price:
    type: Number

  discountCash:
    type: Number

  discountPercent:
    type: Number
    decimal: true
    optional: true

  finalPrice:
    type: Number

  submit:
    type: Boolean
    optional: true


  version: { type: Schema.Version }

Schema.add 'returnDetails'