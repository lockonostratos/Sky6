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
    productDetail = Schema.productDetails.findOne({warehouse: warehouseId,  instockQuality: { $gt: 0 } })
    return console.log('Kho Chưa Có Sản Phẩm') if !productDetail
    option =
      merchant    : warehouse.merchant
      warehouse   : warehouse._id
      creator     : userProfile.user
      description : description
      detail      : false
      resolved    : false
      submit      : false
      success     : false

    option._id = Schema.inventories.insert option, (error, result) -> console.log error if error
    Schema.warehouses.update warehouseId, $set:{checkingInventory: true, inventory: option._id}, (error, result) -> console.log error if error
    option
    InventoryDetail.createByWarehouse(warehouseId)

  inventoryDestroy: ->
    Schema.warehouses.update @data.warehouse,
      $set:{checkingInventory: false}
      $unset:{inventory: ""}

    for detail in Schema.inventoryDetails.find({inventory: @id}).fetch()
      Schema.inventoryDetails.remove detail._id
    Schema.inventories.remove @id
    return console.log 'Hủy Phiếu Kiểm Kho Thành Công'

  inventorySuccess: ->
    for detail in Schema.inventoryDetails.find({inventory: @id}).fetch()
      if detail.lock == false || detail.submit == false
        return console.log 'Xác Nhận Lỗi, Chưa Submited hết các sp'

    temp = false
    for detail in Schema.inventoryDetails.find({inventory: @id}).fetch()
      Schema.inventoryDetails.update detail._id, $set:{success: true}
      if detail.lostQuality != 0
        temp = true

    if temp
      Schema.inventories.update @id, $set:{submit: true}
    else
      Schema.inventories.update @id, $set:{submit: true, success: true}

    Schema.warehouses.update @data.warehouse,
      $set:{checkingInventory: false}
      $unset:{inventory: ""}







