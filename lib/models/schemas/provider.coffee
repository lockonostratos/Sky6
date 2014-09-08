Schema2.providers = new SimpleSchema(
  merchant:
    type: String

  creator:
    type: String

  name:
    type: String

  representative:
    type: String
    optional: true

  phone:
    type: String
    optional: true

  manufacturer:
    type: String
    optional: true

  status:
    type: Boolean
    optional: true


  location: { type: Schema.Location, optional: true }
  version: { type: Schema.Version }
)

Schema.add 'providers'
