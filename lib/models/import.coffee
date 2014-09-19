reUpdateImportDetail = (newImportDetail, oldImportDetail) ->
  Schema.importDetails.update oldImportDetail._id, $inc:{ importQuality : newImportDetail.importQuality}  , (error, result) ->
    console.log result; console.log error if error

Schema.add 'imports', class Import
  @createdByWarehouseAndSelect: (warehouseID, option)->
    return ('Kho không chính xác') if !warehouse = Schema.warehouses.findOne(warehouseID)
    return ('Mô Tả Không Được Đễ Trống') if !option.description
    option.merchant   = warehouse.merchant
    option.warehouse  = warehouse._id
    option.creator    = Meteor.userId()
    option.finish     = false
    option._id = Schema.imports.insert option, (error, result)-> console.log result; console.log error if error
    UserProfile.update {currentImport: option._id}


  addImportDetail: (product, importDetails)->
    importDetail =
      import        : @id
      product       : @data.currentProduct
      name          : product.name
      skulls        : product.skulls
      importQuality : Number(@data.currentQuality)
      importPrice   : Number(@data.currentPrice)
      finish        : false
      color         : Sky.helpers.randomColor()
    importDetail.provider = @data.currentProvider if @data.currentProvider
    importDetail.expire = @data.currentExpire if @data.currentExpire

#    findProduct =_.findWhere(importDetails, {product: @data.currentProduct})
    findImportDetail =_.findWhere(importDetails,{
      product     : importDetail.product
      provider    : importDetail.provider
      importPrice : importDetail.importPrice
    })

    if findImportDetail
      reUpdateImportDetail(importDetail, findImportDetail)
    else
      Schema.importDetails.insert importDetail, (error, result) -> console.log result; console.log error if error
#    updateOrderWhenAddOrderDetail(importDetail, findProduct)



  finishImport: (importDetails)->
    try
#      importDetails = Schema.importDetails.find({import:@id}).fetch()
      if importDetails.length < 1 then throw 'Import rỗng'
      for importDetail in importDetails
        product = Schema.products.findOne importDetail.product
        if !product then throw 'Không tìm thấy Product'
      for importDetail in importDetails
        productDetail={}
        productDetail.import = @id
        productDetail.merchant = @data.merchant
        productDetail.warehouse = @data.warehouse
        productDetail.product = importDetail.product
        productDetail.importQuality = importDetail.importQuality
        productDetail.availableQuality = importDetail.importQuality
        productDetail.instockQuality = importDetail.importQuality
        productDetail.importPrice = importDetail.importPrice

        Schema.productDetails.insert productDetail, (error, result) ->
          if error then throw 'Sai thong Tin San Pham'

        Schema.products.update importDetail.product,
          $inc:
            totalQuality    : importDetail.importQuality
            availableQuality: importDetail.importQuality
            instockQuality  : importDetail.importQuality

      for importDetail in importDetails
        Schema.importDetails.update importDetail._id, $set: {status: true}
      Schema.imports.update @id, $set:{finish: true}
    catch e
      console.log e
      importProductFalse =Schema.productDetails.find(import: @id)
      for importProduct in importProductFalse
        productDetail = Schema.productDetails.remove(importProduct._id)
        Schema.products.update productDetail.product,
          $inc:
            totalQuality    : -productDetail.importQuality
            availableQuality: -productDetail.importQuality
            instockQuality  : -productDetail.importQuality



