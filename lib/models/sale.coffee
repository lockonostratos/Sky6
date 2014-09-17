Schema.add 'sales', class Sale
  addReturnDetail: ->
    saleDetail = Schema.saleDetails.findOne(@data.currentProductDetail)
    returns = Schema.returns.findOne({sale: @id, creator: Meteor.userId(), status: 0})
    returnDetails = Schema.returnDetails.find({returns: returns._id}).fetch() if returns
    console.log returnDetails
    if !returns
      returns =
        merchant       : @data.merchant
        warehouse      : @data.warehouse
        creator        : Meteor.userId()
        sale           : @id
        comment        : 'Trả Hàng'
        returnCode     : "ramdom"
        productSale    : 0
        productQuality : 0
        totalPrice     : 0
        status         : 0
      returns._id = Schema.returns.insert returns
      Schema.sales.update @id, $set:{
        currentReturn : returns._id
        returner      : Meteor.userId()
        status        : false
      }

    returnDetail =
      returns         : returns._id
      product         : saleDetail.product
      productDetail   : saleDetail.productDetail
      name            : saleDetail.name
      skulls          : saleDetail.skulls
      returnQuality   : @data.currentQuality
      price           : saleDetail.price
      submit          : false
      discountPercent : saleDetail.discountPercent
      discountCash    : saleDetail.price * @data.currentQuality * saleDetail.discountPercent
      finalPrice      : saleDetail.price * @data.currentQuality * (100 - saleDetail.discountPercent)/100

    findReturnDetail =_.findWhere(returnDetails,{
      productDetail   : returnDetail.productDetail
      price           : returnDetail.price
      discountPercent : returnDetail.discountPercent
    })

    if findReturnDetail
      return ('Vuot Qua SL Hang Co') if saleDetail.quality < (findReturnDetail.returnQuality + returnDetail.returnQuality)
      Schema.returnDetails.update findReturnDetail._id, $inc:{
        returnQuality : returnDetail.returnQuality
        discountCash  : returnDetail.discountCash
        finalPrice    : returnDetail.finalPrice
      }
    else
      return ('Vuot Qua SL Hang Co') if saleDetail.quality <  returnDetail.returnQuality
      Schema.returnDetails.insert returnDetail

    Schema.returns.update returns._id, $inc: {
      productQuality: returnDetail.returnQuality
      totalPrice    : returnDetail.finalPrice
    }

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

