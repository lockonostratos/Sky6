Schema2.exportDetails = new SimpleSchema
  export:
    type: String

  product:
    type: String

  productDetail:
    type: String

  name:
    type: String

  skulls:
    type: [String]

  quality:
    type: Number

  version: { type: Schema.Version }

Schema.add 'exportDetails'