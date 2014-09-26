Schema2.importDetails = new SimpleSchema
  import:
    type: String

  product:
    type: String

  name:
    type: String

  skulls:
    type: [String]

  provider:
    type: String
    optional: true

  importQuality:
    type: Number

  importPrice:
    type: Number

  totalPrice:
    type: Number

  salePrice:
    type: Number
    optional: true

  expire:
    type: Date
    optional: true

  color:
    type: String
    optional: true

  styles:
    type: String
    optional: true

  finish:
    type: Boolean


  version: { type: Schema.Version }

