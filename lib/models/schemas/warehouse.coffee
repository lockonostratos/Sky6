Schema2.warehouses = new SimpleSchema
  parentMerchant:
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

  checkingInventory:
    type: Boolean

  inventory:
    type: String
    optional: true




  location: { type: Schema.Location, optional: true }
  version: { type: Schema.Version }

