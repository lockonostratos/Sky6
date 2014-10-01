Schema2.userProfiles = new SimpleSchema
  user:
    type: String

  creator:
    type: String
    optional: true

  isRoot:
    type: Boolean

  fullName:
    type: String
    optional: true

  dateOfBirth:
    type: Date
    optional: true

  startWorkingDate:
    type: Date
    optional: true

  roles:
    type: [String]
    optional: true

  parentMerchant:
    type: String

  currentMerchant:
    type: String

  currentWarehouse:
    type: String

  systemVersion:
    type: String
#--------------------------
#--------------------------
  currentOrder:
    type: String
    optional: true

  currentImport:
    type: String
    optional: true

  currentSale:
    type: String
    optional: true

#--------------------------
  currentDeliveryMerchant:
    type: String
    optional: true

  currentDeliveryWarehouse:
    type: String
    optional: true

  currentDeliveryFilter:
    type: Number
    optional: true

  currentDelivery:
    type: String
    optional: true
#---------------------------
  inventoryMerchant:
    type: String
    optional: true

  inventoryWarehouse:
    type: String
    optional: true

  currentInventoryHistory:
    type: String
    optional: true

  currentInventory:
    type: String
    optional: true
#----------------------------


