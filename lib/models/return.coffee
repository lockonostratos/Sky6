Schema.add 'returns', class Return
  @createBySale: (saleId)->
    sale = Schema.sales.findOne({_id: saleId})
    option =
      merchant       : sale.merchant
      warehouse      : sale.warehouse
      creator        : Meteor.userId()
      sale           : sale._id
      comment        : 'Trả Hàng'
      returnCode     : "ramdom"
      productSale    : 0
      productQuality : 0
      totalPrice     : 0
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
    if returns.status == 0
      Schema.returns.update returns._id, $set: {status: 1}
      for returns in Schema.returnDetails.find({returns: returns._id}).fetch()
        Schema.returnDetails.update returns._id, $set: {submit: true}
      return('Ok, Phieu Da Duoc Xac Nhan Tu Nhan Vien')
    return('Loi, Phieu Da Xac Nhan') if returns.status == 1
    return('Loi, Phieu Da Hoan Thanh') if returns.status == 2

  @editReturn: (returnId)->
    returns = Schema.returns.findOne({_id: returnId})
    if returns.status == 1
      Schema.returns.update returns._id, $set: {status: 0}
      for returns in Schema.returnDetails.find({returns: returns._id}).fetch()
        Schema.returnDetails.update returns._id, $set: {submit: false}
      return('Ok, Phieu Da Duoc Bo Xac Nhan')
    return('Loi, Phieu Chua Xac Nhan') if returns.status == 0
    return('Loi, Phieu Da Hoan Thanh') if returns.status == 2

  @submitReturn: (returnId)->
    returns = Schema.returns.findOne({_id: @data.currentReturn, creator: Meteor.userId()})
    if returns.status == 1
      Schema.returns.update returns._id, $set: {status: 2}
      for returnDetail in Schema.returnDetails.find({returns: returns._id}).fetch()
        Schema.productDetails.update returnDetail.productDetail, $inc: {
          availableQuality: returnDetail.returnQuality
          instockQuality  : returnDetail.returnQuality
        }
        Schema.products.update returnDetail.product, $inc: {
          availableQuality: returnDetail.returnQuality
          instockQuality  : returnDetail.returnQuality
        }
      console.log 'Ok, Phieu Da Duoc Xac Nhan Quan Ly'
    return('Loi, Phieu Chua Xac Nhan') if returns.status == 0
    return('Loi, Phieu Da Hoan Thanh') if returns.status == 2

