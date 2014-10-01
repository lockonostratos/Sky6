Schema2.migrations = new SimpleSchema
  systemVersion:
    type: String

  description:
    type: String

  group:
    type: [String]

  color:
    type: String

  version: { type: Schema.Version }

Schema.add 'migrations'