Schema.add 'inventoryDetails', class InventoryDetail
  @createByWarehouse: (warehouseId)->
    return console.log 'Bạn Chưa Đăng Nhập' if !userProfile = Schema.userProfiles.findOne({user: Meteor.userId()})
    warehouse = Schema.warehouses.findOne({
      _id       : warehouseId
      merchant  : userProfile.currentMerchant
       })
    return console.log 'Kho Không Tồn Tại' if !warehouse
    return console.log 'Kho Chưa Tạo Kiểm Kho, Không Thể Tạo Chi Tiết' if warehouse.checkingInventory == false
    return console.log 'Phiếu Kiểm Kho Không Tồn Tại' if !inventory = Schema.inventories.findOne(warehouse.inventory)
    return console.log 'Phiếu Kiểm Kho Đã Có Chi Tiết, Không Thể Tạo Chi Tiết' if inventory.detail == true

    for productDetail in Schema.productDetails.find({warehouse: warehouseId}).fetch()
      option =
        inventory       : warehouse.inventory
        product         : productDetail.product
        productDetail   : productDetail._id
        name            : productDetail.name
        skulls          : productDetail.skulls
        originalQuality : productDetail.instockQuality
        realQuality     : 0
        saleQuality     : 0
        lostQuality     : 0
        resolved        : false
        submit          : false
        success         : false

      console.log Schema.inventoryDetails.insert option, (error, result) -> console.log error if error
    Schema.inventories.update warehouse.inventory, $set: {detail: true}, (error, result) -> console.log error if error
    console.log 'Tao Chi Tiet Kiem Kho Thanh Cong'

