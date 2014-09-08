Schema2.importDetails = new SimpleSchema
  import:
    type: String

  product:
    type: String

  provider:
    type: String
    optional: true

  importQuality:
    type: Number

  importPrice:
    type: Number

  expire:
    type: Date
    optional: true

  version: { type: Schema.Version }

Schema.add 'importDetails'