Schema2.groupTags = new SimpleSchema
  merchant:
    type: String
    optional: true

  creator:
    type: String

  global:
    type: Boolean
    defaultValue: true

  description:
    type: String

  icon:
    type: String
    optional: true

  color:
    type: String
    optional: true

  version: { type: Schema.Version }