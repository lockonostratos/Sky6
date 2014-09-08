Schema2.roles = new SimpleSchema
  group:
    type: String

  owner:
    type: String
    optional: true

  creator:
    type: String
    optional: true

  name:
    type: String
    optional: true

  description:
    type: String

  permissions:
    type: [String]
    optional: true

  version: { type: Schema.Version }