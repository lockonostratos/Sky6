Schema.add 'returnDetails', class ReturnDetail
  @newByReturn : (returnId, saleId)->
    sale = Schema.sales.findOne(saleId)
    saleDetail = Schema.saleDetails.findOne(sale.currentProductDetail)
    option =
      returns         : returnId
      product         : saleDetail.product
      productDetail   : saleDetail.productDetail
      name            : saleDetail.name
      skulls          : saleDetail.skulls
      returnQuality   : sale.currentQuality
      price           : saleDetail.price
      submit          : false
      discountPercent : saleDetail.discountPercent
      discountCash    : saleDetail.price * sale.currentQuality * saleDetail.discountPercent
      finalPrice      : Math.round(saleDetail.price * sale.currentQuality * (100 - saleDetail.discountPercent)/100)
    option

  @addReturnDetail: (saleId)->
    return('Phiếu bán hàng không tồn tại') if !sale = Schema.sales.findOne({_id: saleId})
    return("Chưa chọn sản phẩm trả hàng") if !sale.currentProductDetail
    return("Sản phẩm trả hàng không tồn tại") if !saleDetail = Schema.saleDetails.findOne({_id: sale.currentProductDetail})
    return("Số lượng sản phẩm phải lớn hơn 0") if sale.currentQuality <= 0

    if returns = Schema.returns.findOne({_id: sale.currentReturn})
      return("Phiếu đang chờ duyệt, không thể thêm sản phẩm.") if returns.status == 1
      returns = Return.createBySale(saleId) if returns.status == 2
    else
      returns = Return.createBySale(saleId)

    returnDetail = ReturnDetail.newByReturn(returns._id, saleId)
    returnDetails = Schema.returnDetails.find({returns: returns._id}).fetch()

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

