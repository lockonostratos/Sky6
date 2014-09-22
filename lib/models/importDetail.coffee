reUpdateImportDetail = (newImportDetail, oldImportDetail) ->
  Schema.importDetails.update oldImportDetail._id, $inc:{ importQuality : newImportDetail.importQuality}
  , (error, result) -> console.log error if error


Schema.add 'importDetails', class ImportDetail
  @newImportDetail: (imports, product)->
    option=
      import        : imports._id
      product       : imports.currentProduct
      name          : product.name
      skulls        : product.skulls
      importQuality : Number(imports.currentQuality)
      importPrice   : Number(imports.currentPrice)
      finish        : false

      styles        : Sky.helpers.randomColor()
    option.provider = imports.currentProvider if imports.currentProvider
    option.expire = imports.currentExpire if imports.currentExpire
    option


  @createByImport: (importId)->
    if !imports = Schema.imports.findOne({_id: importId}) then return {error: true, message: "Phiếu nhập kho không tồn tại"}
    if imports.finish == true then return {error: true, message: "Phiếu nhập kho đang chờ duyệt, không thể thêm sản phẩm"}
    if !product = Schema.products.findOne(imports.currentProduct) then return {error: true, message: "Không tìm thấy sản phẩm nhập kho"}
    importDetails = Schema.importDetails.find({import: importId}).fetch()
    importDetail = @newImportDetail(imports, product)

    findImportDetail =_.findWhere(importDetails,{
      product     : importDetail.product
      provider    : importDetail.provider
      importPrice : importDetail.importPrice
    })

    if findImportDetail
      reUpdateImportDetail(importDetail, findImportDetail)
    else
      Schema.importDetails.insert importDetail, (error, result) -> console.log error if error

    Sky.global.reCalculateImport(importId)