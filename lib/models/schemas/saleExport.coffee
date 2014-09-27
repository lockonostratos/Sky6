Schema2.saleExports = new SimpleSchema
  merchant:
    type: String

  warehouse:
    type: String

  creator:
    type: String

  sale:
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

  qualityExport:
    type: Number

  styles:
    type: String
    optional: true

  version: { type: Schema.Version }

