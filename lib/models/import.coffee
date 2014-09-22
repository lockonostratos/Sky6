Sky.global.reCalculateImport = (importId)->
  if !warehouseImport = Schema.imports.findOne(importId) then console.log('Sai Import'); return
  if !importDetails = Schema.importDetails.find({import: importId}).fetch() then console.log('Sai Import'); return
  if importDetails.length > 0
    totalPrice = 0
    for detail in importDetails
      totalPrice += (detail.importQuality * detail.importPrice)
    Schema.imports.update importId, $set: {totalPrice: totalPrice}
  else
    Schema.imports.update importId, $set: {totalPrice: 0}

Schema.add 'imports', class Import
  @removeAll: (importId)->
#    return ('Chua Dang Nhap') if !userProfile = Sky.global.userProfile()
    return ("Phiếu nhập kho không tồn tại") if !imports = Schema.imports.findOne({_id: importId, finish: false})
    return ("Phiếu nhập kho đã duyệt, không thể xóa") if imports.submited == true
    return ("Phiếu nhập kho đang chờ duyệt, không thể xóa") if imports.finish == true

    for importDetail in Schema.importDetails.find({import: imports._id}).fetch()
      Schema.importDetails.remove(importDetail._id)
    Schema.imports.remove(imports._id)
    return ("Đã xóa thành công phiếu nhập kho")

  @createdByWarehouseAndSelect: (warehouseId, option)->
    return ('Kho không chính xác') if !warehouse = Schema.warehouses.findOne(warehouseId)
    return ('Mô Tả Không Được Đễ Trống') if !option.description
    option.merchant   = warehouse.merchant
    option.warehouse  = warehouse._id
    option.creator    = Meteor.userId()
    option.finish     = false
    option.submited   = false
    option._id = Schema.imports.insert option, (error, result)-> console.log error if error
    UserProfile.update {currentImport: option._id}

  @finishImport: (importId)->
    return('Bạn chưa đăng nhập') if !userProfile = Sky.global.userProfile()
    return('Phiếu nhập kho không tồn tại') if !imports = Schema.imports.findOne({_id: importId})
    return ("Phiếu nhập kho đã duyệt, không thể chờ duyệt") if imports.submited == true && imports.finish == true
    return ("Phiếu nhập kho đã đang chờ duyệt") if imports.submited == false && imports.finish == true
    importDetails = Schema.importDetails.find({import: importId}).fetch()
    return('Phiếu nhập kho rỗng, hay thêm sản phẩm') if importDetails.length < 1

    if imports.finish == false && imports.submited == false
      for importDetail in importDetails
        Schema.importDetails.update importDetail._id, $set: {finish: true}
      Schema.imports.update importId, $set:{finish: true}
      return ('Phiếu nhập kho đang chờ duyệt')
    else
      return ('Đã có lỗi trong quá trình xác nhận')

  @editImport: (importId)->
    return('Bạn chưa đăng nhập') if !userProfile = Sky.global.userProfile()
    return('Phiếu nhập kho không tồn tại') if !imports = Schema.imports.findOne({_id: importId})
    return ("Phiếu nhập kho đã duyệt, không thể chỉnh sửa") if imports.submited == true && imports.finish == true
    return ("Phiếu nhập kho đang có thể chỉnh sửa") if imports.finish == false && imports.submited == false
    importDetails = Schema.importDetails.find({import: importId}).fetch()
    return ('Phiếu nhập kho rỗng, hay thêm sản phẩm') if importDetails.length < 1

    if imports.finish == true && imports.submited == false
      for importDetail in importDetails
        Schema.importDetails.update importDetail._id, $set: {finish: false}
      Schema.imports.update importId, $set:{finish: false}
      return ('Phiếu nhập kho đã có thể chỉnh sửa')
    else
      return ('Đã có lỗi trong quá trình xác nhận')

  @submitedImport: (importId)->
    return('Bạn chưa đăng nhập') if !userProfile = Sky.global.userProfile()
    return('Phiếu nhập kho không tồn tại') if !imports = Schema.imports.findOne({_id: importId})
    return ("Phiếu nhập kho đã duyệt, không thể duyệt lần thứ nữa") if imports.submited == true && imports.finish == true
    return ("Phiếu nhập kho chưa chờ duyệt") if imports.finish == false && imports.submited == false

    importDetails = Schema.importDetails.find({import: importId, finish: true}).fetch()
    return ('Phiếu nhập kho rỗng, hay thêm sản phẩm') if importDetails.length < 1

    if imports.finish == true && imports.submited == false
#      for importDetail in importDetails
#        product = Schema.products.findOne importDetail.product
#        return ('Không tìm thấy Product') if !product
      for importDetail in importDetails
        productDetail= ProductDetail.newProductDetail(imports, importDetail)
        Schema.productDetails.insert productDetail, (error, result) ->
          if error then throw 'Sai thong Tin San Pham'

        Schema.products.update importDetail.product,
          $inc:
            totalQuality    : importDetail.importQuality
            availableQuality: importDetail.importQuality
            instockQuality  : importDetail.importQuality

        Schema.importDetails.update importDetail._id, $set: {finish: true}
      Schema.imports.update importId, $set:{finish: true, submited: true}
      return ('Phiếu nhập kho đã được duyệt')
    else
      return ('Đã có lỗi trong quá trình xác nhận')

#    importProductFalse = Schema.productDetails.find(import: @id)
#
#    for importProduct in importProductFalse
#      productDetail = Schema.productDetails.remove(importProduct._id)
#      Schema.products.update productDetail.product,
#        $inc:
#          totalQuality    : -productDetail.importQuality
#          availableQuality: -productDetail.importQuality
#          instockQuality  : -productDetail.importQuality



#
#try
##      importDetails = Schema.importDetails.find({import:@id}).fetch()
#  if importDetails.length < 1 then throw 'Import rỗng'
#  for importDetail in importDetails
#    product = Schema.products.findOne importDetail.product
#    if !product then throw 'Không tìm thấy Product'
#  for importDetail in importDetails
#    productDetail={}
#    productDetail.import = @id
#    productDetail.merchant = @data.merchant
#    productDetail.warehouse = @data.warehouse
#    productDetail.product = importDetail.product
#    productDetail.importQuality = importDetail.importQuality
#    productDetail.availableQuality = importDetail.importQuality
#    productDetail.instockQuality = importDetail.importQuality
#    productDetail.importPrice = importDetail.importPrice
#
#    Schema.productDetails.insert productDetail, (error, result) ->
#      if error then throw 'Sai thong Tin San Pham'
#
#    Schema.products.update importDetail.product,
#      $inc:
#        totalQuality    : importDetail.importQuality
#        availableQuality: importDetail.importQuality
#        instockQuality  : importDetail.importQuality
#
#  for importDetail in importDetails
#    Schema.importDetails.update importDetail._id, $set: {status: true}
#  Schema.imports.update @id, $set:{finish: true}
#catch e
#  console.log e
#  importProductFalse =Schema.productDetails.find(import: @id)
#  for importProduct in importProductFalse
#    productDetail = Schema.productDetails.remove(importProduct._id)
#    Schema.products.update productDetail.product,
#      $inc:
#        totalQuality    : -productDetail.importQuality
#        availableQuality: -productDetail.importQuality
#        instockQuality  : -productDetail.importQuality
