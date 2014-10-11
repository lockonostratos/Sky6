reUpdateMetroSummary=(importId)->
  imports = Schema.imports.findOne(importId)
  oldImports = Schema.imports.findOne({$and: [
    {merchant: imports.merchant}
    {'version.updateAt': {$lt: imports.version.updateAt}}
    {submited: true}
  ]}, Sky.helpers.defaultSort())
  console.log imports.version.updateAt.getDate()
  console.log oldImports

  unless oldImports
    oldImports = {version: {}}
    oldImports.version.updateAt = imports.version.updateAt

  importDetails = Schema.importDetails.find({import: imports._id, finish: true}).fetch()
  totalProduct = 0
  for importDetail in importDetails
    totalProduct += importDetail.importQuality

  setOption={}
  option =
    importCount: totalProduct
    stockProductCount: totalProduct
    availableProductCount: totalProduct

  if imports.version.updateAt.getDate() == oldImports.version.updateAt.getDate()
    option.importCountDay = totalProduct
  else
    setOption.importCountDay = totalProduct

  if imports.version.updateAt.getMonth() == oldImports.version.updateAt.getMonth()
    option.importCountMonth = totalProduct
  else
    setOption.importCountMonth = totalProduct

  metroSummary = Schema.metroSummaries.findOne({merchant: imports.merchant})
  console.log option
  console.log metroSummary
  Schema.metroSummaries.update metroSummary._id, $inc: option, $set: setOption


createTransactionAndDetailByImport = (importId)->
  warehouseImport = Schema.imports.findOne(importId)
  transaction = Transaction.newByImport(warehouseImport)
  transactionDetail = TransactionDetail.newByTransaction(transaction)

removeOrderAndOrderDetailAfterCreateSale= (orderId)->
  allTabs = Schema.orders.find({creator: Meteor.userId()}).fetch()
  currentSource = _.findWhere(allTabs, {_id: orderId})
  currentIndex = allTabs.indexOf(currentSource)
  currentLength = allTabs.length
  if currentLength == 1
    Order.createOrderAndSelect()
    Order.removeAll(orderId)
  if currentLength > 1
    UserProfile.update {currentOrder: allTabs[currentIndex-1]._id}
    Order.removeAll(orderId)

Sky.global.reCalculateImport = (importId)->
  if !warehouseImport = Schema.imports.findOne(importId) then console.log('Sai Import'); return
  if !importDetails = Schema.importDetails.find({import: importId}).fetch() then console.log('Sai Import'); return
  if importDetails.length > 0
    totalPrice = 0
    for detail in importDetails
      totalPrice += (detail.importQuality * detail.importPrice)
    Schema.imports.update importId, $set: {totalPrice: totalPrice, deposit: totalPrice, debit: 0}
  else
    Schema.imports.update importId, $set: {totalPrice: 0, deposit: 0, debit: 0}

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
    option.totalPrice = 0
    option.deposit    = 0
    option.debit      = 0
    option.emailCreator = Meteor.user().emails[0].address
    option._id = Schema.imports.insert option, (error, result)-> console.log error if error
    UserProfile.update {currentImport: option._id}
    option

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
      for importDetail in importDetails
        product = Schema.products.findOne importDetail.product
        return ('Không tìm thấy sản phẩm id:'+ importDetail.product) if !product

      for importDetail in importDetails
        productDetail= ProductDetail.newProductDetail(imports, importDetail)
        Schema.productDetails.insert productDetail, (error, result) ->
          if error then return 'Sai thông tin sản phẩm nhập kho'

        product = Schema.products.findOne importDetail.product
        option1=
          totalQuality    : importDetail.importQuality
          availableQuality: importDetail.importQuality
          instockQuality  : importDetail.importQuality

        option2=
          provider    : importDetail.provider
          importPrice : importDetail.importPrice
        option2.price = importDetail.salePrice if importDetail.salePrice

        Schema.products.update product._id, $inc: option1, $set: option2, (error, result) ->
          if error then return 'Sai thông tin sản phẩm nhập kho'

      Schema.imports.update importId, $set:{finish: true, submited: true}
      createTransactionAndDetailByImport(importId)
      reUpdateMetroSummary(importId)
      return ('Phiếu nhập kho đã được duyệt')
    else
      return ('Đã có lỗi trong quá trình xác nhận')

