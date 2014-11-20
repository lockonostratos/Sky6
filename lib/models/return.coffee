Sky.global.reCalculateReturn = (returnId)->
  return console.log("Phiếu trả hàng không tồn tại.") if !saleReturn = Schema.returns.findOne(returnId)
  returnDetails = Schema.returnDetails.find({return: saleReturn._id}).fetch()
  option=
    totalPrice     :0
    productQuality :0
    productSale    :0

  if returnDetails.length > 0
    for detail in returnDetails
#      discountPercent
      option.totalPrice     += Math.round(detail.price * detail.returnQuality * (100 - detail.discountPercent)/100)
      option.productQuality += detail.returnQuality
      option.productSale    += 1

    option.discountCash = (saleReturn.discountPercent * option.totalPrice)/100
    option.finallyPrice = option.totalPrice - option.discountCash
  Schema.returns.update saleReturn._id, $set: option

Schema.add 'returns', class Return
  @createBySale: (saleId)->
    return console.log("Phiếu bán hàng không tồn tại.") if !sale = Schema.sales.findOne({_id: saleId})
    return console.log("Không thể tạo phiếu trả hàng mới, phiếu trả hàng cũ chưa kết thúc.") if sale.status == false
    option =
      merchant       : sale.merchant
      warehouse      : sale.warehouse
      creator        : Meteor.userId()
      creatorName    : Meteor.user().emails[0].address
      sale           : sale._id
      comment        : 'Trả Hàng'
      returnCode     : "ramdom"
      productSale    : 0
      productQuality : 0
      discountCash   : 0
      discountPercent: 0
      totalPrice     : 0
      finallyPrice   : 0
      status         : 0
    option._id = Schema.returns.insert option
    Schema.sales.update sale._id, $set:{
      currentReturn : option._id
      returner      : Meteor.userId()
      status        : false
    }
    option

  finishReturn: ->
    try
      userProfile = Schema.userProfiles.findOne({user: Meteor.userId()})
      throw 'Lỗi, Phiếu trả không chính xác.' if @data.creator isnt Meteor.userId()
      throw 'Lỗi, Phiếu trả hàng rỗng, không thể xác nhận.' if Schema.returnDetails.find({return: @id}).count() < 1
      throw 'Lỗi, Bạn không có quyền.' unless Role.hasPermission(userProfile._id, Sky.system.merchantPermissions.returnCreate.key)
      if @data.status == 0
        Notification.returnConfirm(@id)
        Schema.returns.update @id, $set: {status: 1}
        for returnDetail in Schema.returnDetails.find({return: @id, submit: false}).fetch()
          Schema.returnDetails.update returnDetail._id, $set: {submit: true}
        throw 'Ok, Phiếu đã được xác nhận từ nhân viên'
      throw 'Lỗi, Phiếu đã được xác nhận, đang chờ duyệt, không thể thao tác.' if @data.status == 1
      throw 'Lỗi, Phiếu đã được duyệt, không thể thao tác.' if @data.status == 2
    catch error
      console.log error

  editReturn: ->
    try
      throw 'Lỗi, Phiếu trả không chính xác.' if @data.creator isnt Meteor.userId()
      if @data.status == 1
        Schema.returns.update @id, $set: {status: 0}
        for returnDetail in Schema.returnDetails.find({return: @id, submit: true}).fetch()
          Schema.returnDetails.update returnDetail._id, $set: {submit: false}
        throw 'Ok, Phiếu đã có thể chỉnh sửa.'
      throw 'Lỗi, Phiếu chưa được xác nhận từ nhân viên.' if @data.status == 0
      throw 'Lỗi, Phiếu đã được duyệt, không thể thao tác.' if @data.status == 2
    catch error
      console.log error

  submitReturn: ->
    try
      userProfile = Schema.userProfiles.findOne({user: Meteor.userId()})
      throw 'Bạn không có quyền xác nhận.' unless Role.hasPermission(userProfile._id, Sky.system.merchantPermissions.saleExport.key)
      if @data.status == 1
        Notification.returnSubmit(@id)
        returnQuality = 0
        for returnDetail in Schema.returnDetails.find({return: @id, submit: true}).fetch()
          returnQuality = returnDetail.returnQuality
          option =
            availableQuality: returnDetail.returnQuality
            inStockQuality  : returnDetail.returnQuality

          Schema.productDetails.update returnDetail.productDetail, $inc: option
          Schema.products.update returnDetail.product, $inc: option
          Schema.saleDetails.update returnDetail.saleDetail, $inc:{returnQuality: returnDetail.returnQuality}
          saleDetail = Schema.saleDetails.findOne(returnDetail.saleDetail)
          unless saleDetail.quality is saleDetail.returnQuality then unLockReturn = true

        Schema.returns.update @id, $set: {status: 2}
        Schema.sales.update @data.sale, $set:{status: true, return: true, returnLock: !unLockReturn}, $inc:{returnCount: 1, returnQuality: returnQuality}
        transaction =  Transaction.newByReturn(@data)
        transactionDetail = TransactionDetail.newByTransaction(transaction)
        MetroSummary.updateMetroSummaryByReturn(@id, returnQuality)
        throw 'Ok, Phiếu đã được duyệt bởi quản lý.'
      throw 'Lỗi, Phiếu chưa được xác nhận từ nhân viên.' if @data.status == 0
      throw 'Lỗi, Phiếu đã được duyệt, không thể thao tác.' if @data.status == 2
    catch error
      console.log error
