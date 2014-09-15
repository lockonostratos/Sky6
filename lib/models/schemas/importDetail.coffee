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

  expire:
    type: Date
    optional: true

  color:
    type: String

  finish:
    type: Boolean


  version: { type: Schema.Version }

Schema.add 'importDetails'