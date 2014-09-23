Schema2.roles = new SimpleSchema
  group:
    type: String

  parentMerchant:
    type: String
    optional: true

  creator:
    type: String
    optional: true

  name:
    type: String

  description:
    type: String
    optional: true

  roles:
    type: String
    optional: true

  permissions:
    type: [String]
    optional: true

  version: { type: Schema.Version }