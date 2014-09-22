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
    optional: true

  description:
    type: String

  roles:
    type: String
    optional: true

  permissions:
    type: [String]
    optional: true

  version: { type: Schema.Version }