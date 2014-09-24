Schema2.userProfiles = new SimpleSchema
  creator:
    type: String
    optional: true

  user:
    type: String

  fullName:
    type: String
    optional: true

  dateOfBirth:
    type: Date
    optional: true

  startWorkingDate:
    type: Date
    optional: true

  isRoot:
    type: Boolean

  parentMerchant:
    type: String

  currentMerchant:
    type: String

  currentWarehouse:
    type: String

  currentOrder:
    type: String
    optional: true

  currentImport:
    type: String
    optional: true

  currentSale:
    type: String
    optional: true

  currentDelivery:
    type: String
    optional: true

  roles:
    type: [String]
    optional: true

#Schema.add 'userProfiles'