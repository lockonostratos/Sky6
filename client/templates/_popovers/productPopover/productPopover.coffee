createProduct= (event, template)->
  if template.find(".productCode").value.length < 1 || template.find(".productCode").value.length > 15
    Session.set 'errorProductPopover', 'Mã sản phẩm có từ 10 đến 13 ký tự '; return
  else
    Session.set 'errorProductPopover'

  if template.find(".name").value.length < 1
    Session.set 'errorProductPopover', 'Tên sản phẩm phải lớn hơn 1 ký tự '; return
  else
    Session.set 'errorProductPopover'

  if template.find(".skull").value.length < 1
    Session.set 'errorProductPopover', 'Loại sản phẩm không được để trống '; return
  else
    Session.set 'errorProductPopover'

  product =
    merchant         : Session.get('currentMerchant')._id
    warehouse        : Session.get('currentWarehouse')._id
    creator          : Meteor.userId()
    productCode      : template.find(".productCode").value
    name             : template.find(".name").value
    skulls           : [template.find(".skull").value]
    totalQuality     : 0
    availableQuality : 0
    instockQuality   : 0
    price            : 0

  findProduct =  Schema.products.findOne({
    merchant    : product.merchant
    warehouse   : product.warehouse
    productCode : product.productCode
    skulls      : product.skulls})

  if findProduct
    Session.set 'errorProductPopover', 'Sản phẩm tạo mới bị trùng lặp, kiểm tra lại.'
  else
    Schema.products.insert product, (e,r)->
      if r
        template.find(".productCode").value = null
        template.find(".name").value = null
        template.find(".skull").value = null
      else
        Session.set 'errorProductPopover', 'Có lỗi trong quá trình tạo'
        console.log e


Sky.template.extends Template.productPopover,
  error: -> Session.get 'errorProductPopover'
  productList: -> Session.get 'personalNewProducts'

  events:
    'click .createProduct': (event, template)->createProduct(event, template)
    'click .removeProduct': (event, template)->
      product = Product.findOne(@_id)
      if product.data.totalQuality == 0
        Schema.products.remove product.id
      else
        console.log 'Loi, Khong The Xoa Duoc'
