Schema.add 'inventories', class Inventory
  @createByWarehouse: (warehouseId, description)->
    try
      throw 'Bạn chưa đăng nhập.' unless userProfile = Schema.userProfiles.findOne({user: Meteor.userId()})
      throw 'Bạn không có quyền tạo phiếu kiểm kho.' unless Role.hasPermission(userProfile._id, Sky.system.merchantPermissions.inventoryCreate.key)
      throw 'Kho không tồn tại.' unless warehouse = Schema.warehouses.findOne({_id: warehouseId, merchant: userProfile.currentMerchant})
      throw 'Kho đang kiểm kho, không thể tạo phiếu kiểm kho mới' if warehouse.checkingInventory == true
      throw 'Kho trống, không thể kiểm kho.' unless Schema.productDetails.findOne({warehouse: warehouseId,  inStockQuality: { $gt: 0 } })

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
      Schema.warehouses.update warehouseId, $set:{checkingInventory: true, inventory: option._id}, (error, result) -> throw error if error
      InventoryDetail.createByWarehouse(warehouseId)
      throw 'Tạo phiếu kiểm kho thành công.'
    catch error
      console.log error

  inventoryDestroy: ->
    try
      throw 'Bạn chưa đăng nhập.' unless userProfile = Schema.userProfiles.findOne({user: Meteor.userId()})
      throw 'Bạn không có quyền hủy phiếu kiểm kho.' unless Role.hasPermission(userProfile._id, Sky.system.merchantPermissions.inventoryDestroy.key)
      throw 'Kho không tồn tại.' unless Schema.warehouses.findOne({_id: @data.warehouse, merchant: userProfile.currentMerchant})

      Schema.warehouses.update @data.warehouse,
        $set:{checkingInventory: false}
        $unset:{inventory: ""}

      for detail in Schema.inventoryDetails.find({inventory: @id}).fetch()
        Schema.inventoryDetails.remove detail._id
      Schema.inventories.remove @id
      throw 'Hủy Phiếu Kiểm Kho Thành Công'
    catch error
      console.log error

  inventorySuccess: ->
    try
      throw 'Bạn chưa đăng nhập.' unless userProfile = Schema.userProfiles.findOne({user: Meteor.userId()})
      throw 'Bạn không có quyền xác nhận phiếu kiểm kho.' unless Role.hasPermission(userProfile._id, Sky.system.merchantPermissions.inventoryConfirm.key)
      throw 'Kho không tồn tại' if !warehouse = Schema.warehouses.findOne(@data.warehouse)

      for detail in Schema.inventoryDetails.find({inventory: @id}).fetch()
        throw 'Lỗi, Chưa Submitted hết các sp' if detail.lock == false || detail.submit == false

      temp = false
      for detail in Schema.inventoryDetails.find({inventory: @id}).fetch()
        option =
          realQuality : detail.realQuality-detail.saleQuality
          saleQuality : 0
          success     : true
          successDate : new Date
          status      : true

        if detail.lostQuality > 0
          temp = true
          option.status = false
          updateProduct =
            inStockQuality   : -detail.lostQuality
            availableQuality : -detail.lostQuality

          Schema.productLosts.insert ProductLost.new(warehouse, detail)
          Schema.products.update detail.product, $inc: updateProduct, (error, result) -> console.log error if error
          Schema.productDetails.update detail.productDetail, $inc: updateProduct, (error, result) -> console.log error if error
        Schema.inventoryDetails.update detail._id, $set: option, (error, result) -> console.log error if error

      Notification.inventoryNewCreate(@id)
      updateInventory = {submit: true, success: true}
      if temp then updateInventory.success = false
      Schema.inventories.update @id, $set: updateInventory

      Schema.warehouses.update @data.warehouse,
        $set:{checkingInventory: false}
        $unset:{inventory: ""}

      MetroSummary.updateMetroSummaryByInventory(@id)
      throw 'Đã Xác Nhận Kiểm Kho.'
    catch error
      console.log







