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

  @finishReturn: (returnId)->
    returns = Schema.returns.findOne({_id: returnId})
    return console.log('Lỗi, Phiếu trả hàng không tồn tại.') if !returns
    return console.log('Lỗi, Phiếu trả hàng rỗng, không thể xác nhận.') if Schema.returnDetails.find({return: returns._id}).fetch().length < 1
    if returns.status == 0
      Schema.returns.update returns._id, $set: {status: 1}
      for returns in Schema.returnDetails.find({return: returns._id, submit: false}).fetch()
        Schema.returnDetails.update returns._id, $set: {submit: true}
      return console.log('Ok, Phiếu đã được xác nhận từ nhân viên')
    return console.log('Lỗi, Phiếu đã được xác nhận, đang chờ duyệt, không thể thao tác.') if returns.status == 1
    return console.log('Lỗi, Phiếu đã được duyệt, không thể thao tác.') if returns.status == 2

  @editReturn: (returnId)->
    returns = Schema.returns.findOne({_id: returnId})
    return console.log('Lỗi, Phiếu không tồn tại.') if !returns
    if returns.status == 1
      Schema.returns.update returns._id, $set: {status: 0}
      for returns in Schema.returnDetails.find({return: returns._id, submit: true}).fetch()
        Schema.returnDetails.update returns._id, $set: {submit: false}
      return console.log('Ok, Phiếu đã có thể chỉnh sửa.')
    return console.log('Lỗi, Phiếu chưa được xác nhận từ nhân viên.') if returns.status == 0
    return console.log('Lỗi, Phiếu đã được duyệt, không thể thao tác.') if returns.status == 2

  @submitReturn: (returnId)->
    returns = Schema.returns.findOne({_id: returnId})
    return console.log('Lỗi, Phiếu không tồn tại.') if !returns
    if returns.status == 1
      returnQuality = 0
      for returnDetail in Schema.returnDetails.find({return: returns._id, submit: true}).fetch()
        returnQuality = returnDetail.returnQuality
        option =
          availableQuality: returnDetail.returnQuality
          instockQuality  : returnDetail.returnQuality

        Schema.productDetails.update returnDetail.productDetail, $inc: option
        Schema.products.update returnDetail.product, $inc: option
        Schema.saleDetails.update returnDetail.saleDetail, $inc:{returnQuality: returnDetail.returnQuality}


      Schema.returns.update returns._id, $set: {status: 2}
      Schema.sales.update returns.sale, $set:{status: true, return: true}, $inc:{returnCount: 1, returnQuality: returnQuality}
      transaction =  Transaction.newByReturn(returns)
      transactionDetail = TransactionDetail.newByTransaction(transaction)
      MetroSummary.updateMetroSummaryByReturn(returns._id, returnQuality)


      return console.log('Ok, Phiếu đã được duyệt bởi quản lý.')
    return console.log('Lỗi, Phiếu chưa được xác nhận từ nhân viên.') if returns.status == 0
    return console.log('Lỗi, Phiếu đã được duyệt, không thể thao tác.') if returns.status == 2

