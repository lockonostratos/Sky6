Schema.add 'inventories', class Inventory
  @createByWarehouse: (warehouseId, description)->
#    return console.log 'Lý Do Nhập Kho Trống' if !description
    return console.log 'Bạn Chưa Đăng Nhập' if !userProfile = Schema.userProfiles.findOne({user: Meteor.userId()})
    warehouse = Schema.warehouses.findOne({
      _id       : warehouseId
      merchant  : userProfile.currentMerchant
    })
    return console.log('Kho Không Tồn Tại') if !warehouse
    return console.log 'Kho Đang Kiểm Kho, Không Thễ Tạo Phiếu Mới' if warehouse.checkingInventory == true

    option =
      merchant    : warehouse.merchant
      warehouse   : warehouse._id
      creator     : userProfile.user
      description : 'nhap kho lan dau'
      detail      : false
      resolved    : false
      submit      : false
      success     : false

    option._id = Schema.inventories.insert option, (error, result) -> console.log error if error
    Schema.warehouses.update warehouseId, $set:{checkingInventory: true, inventory: option._id}, (error, result) -> console.log error if error
    option
    InventoryDetail.createByWarehouse(warehouseId)

  @destroy: (inventoryId)->
    inventory = Schema.inventories.findOne(inventoryId)
    Schema.warehouses.update inventory.warehouse,
      $set:{checkingInventory: false}
      $unset:{inventory: ""}

    for detail in Schema.inventoryDetails.find({inventory: inventoryId}).fetch()
      Schema.inventoryDetails.remove detail._id
    Schema.inventories.remove inventoryId
    return console.log 'Hủy Phiếu Kiểm Kho Thành Công'







