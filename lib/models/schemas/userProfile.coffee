Schema2.userProfiles = new SimpleSchema
  user:
    type: String

  isRoot:
    type: Boolean

  creator:
    type: String
    optional: true

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
    defaultValue: 'images/avatars/no-avatar.jpg'

  startWorkingDate:
    type: Date
    optional: true

  roles:
    type: [String]
    optional: true

  parentMerchant:
    type: String
    optional: true

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
#  companyName:
#    type: String
#    optional: true
#
#  companyPhone:
#    type: String
#    optional: true
#
#  merchantName:
#    type: String
#    optional: true
#
#  warehouseName:
#    type: String
#    optional: true
#
#  packageClass:
#    type: String
#    optional: true
#
#  extendAccountLimit:
#    type: Number
#    optional: true
#
#  extendBranchLimit:
#    type: Number
#    optional: true
#
#  extendWarehouseLimit:
#    type: Number
#    optional: true
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

