Schema2.skulls = new SimpleSchema
  merchant:
    type: String

  creator:
    type: String

  name:
    type: String

  value:
    type: String
    optional: true

  version: { type: Schema.Version }