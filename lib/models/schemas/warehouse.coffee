Schema2.warehouses = new SimpleSchema
  parentMerchnat:
    type: String
    optional: true

  merchant:
    type: String


  creator:
    type: String

  name:
    type: String

  isRoot:
    type: Boolean

  location: { type: Schema.Location, optional: true }
  version: { type: Schema.Version }

