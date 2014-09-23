Schema.add 'sales', class Sale
  @newByOrder: (order)->
    option =
      merchant     : order.merchant
      warehouse    : order.warehouse
      creator      : order.creator
      seller       : order.seller
      buyer        : order.buyer
      orderCode    : order.orderCode
      productCount : order.productCount
      saleCount    : order.saleCount
      return       : false
      deliveryType : order.deliveryType
      paymentMethod: order.paymentMethod
      billDiscount : order.billDiscount
      discountCash : order.discountCash
      totalPrice   : order.totalPrice
      finalPrice   : order.finalPrice
      deposit      : order.deposit
      debit        : order.debit
      status       : false
    option

  finishReturn: ->
    returns = Schema.returns.findOne({_id: @data.currentReturn, creator: Meteor.userId()})
    if returns.status == 0
      Schema.returns.update returns._id, $set: {status: 1}
      for returns in Schema.returnDetails.find({returns: returns._id}).fetch()
        Schema.returnDetails.update returns._id, $set: {submit: true}
      console.log 'Ok, Phieu Da Duoc Xac Nhan Tu Nhan Vien'
    if returns.status == 1 then console.log 'Loi, Phieu Da Xac Nhan'
    if returns.status == 2 then console.log 'Loi, Phieu Da Hoan Thanh'

  editReturn: ->
    returns = Schema.returns.findOne({_id: @data.currentReturn, creator: Meteor.userId()})
    if returns.status == 1
      Schema.returns.update returns._id, $set: {status: 0}
      for returns in Schema.returnDetails.find({returns: returns._id}).fetch()
        Schema.returnDetails.update returns._id, $set: {submit: false}
      console.log 'Ok, Phieu Da Duoc Bo Xac Nhan'
    if returns.status == 0 then console.log 'Loi, Phieu Chua Xac Nhan'
    if returns.status == 2 then console.log 'Loi, Phieu Da Hoan Thanh'

  submitReturn: ->
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
    if returns.status == 0 then console.log 'Loi, Phieu Chua Xac Nhan'
    if returns.status == 2 then console.log 'Loi, Phieu Da Hoan Thanh'

