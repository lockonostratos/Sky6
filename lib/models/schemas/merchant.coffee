Schema2.merchants = new SimpleSchema
  parent:
    type: String
    optional: true

  creator:
    type: String
    optional: true

  owner:
    type: String
    optional: true

  name:
    type: String

  address:
    type: String
    optional: true

  location:
    type: [String]
    optional: true

  area:
    type: [String]
    optional: true

  version: { type: Schema.Version }