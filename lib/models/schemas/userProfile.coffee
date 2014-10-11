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

  gender:
    type: Boolean
    optional: true

  avatar:
    type: String
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
    optional: true

  currentWarehouse:
    type: String
    optional: true

  systemVersion:
    type: String
    optional: true
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
  exportMerchant:
    type: String
    optional: true

  exportWarehouse:
    type: String
    optional: true

  targetExportMerchant:
    type: String
    optional: true

  targetExportWarehouse:
    type: String
    optional: true

  exportProduct:
    type: String
    optional: true

  exportQuality:
    type: Number
    optional: true
#----------------------------

