Schema2.migrations = new SimpleSchema
  systemVersion:
    type: String

  creator:
    type: String
    optional: true

  owner:
    type: String
    optional: true

  description:
    type: String

  group:
    type: [String]

  color:
    type: String
    optional: true

  version: { type: Schema.Version }

Schema.add 'migrations'