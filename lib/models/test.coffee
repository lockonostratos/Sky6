#root = global ? window
#Deps.autorun ->
#  Template.addImportDetail.productList = Schema.products.find({}).fetch()
#  if Session.get('currentOrder') then Session.set 'currentOrderDetails', Schema.orderDetails.find({order: Session.get('currentOrder')._id }).fetch()
#
##---- Import --------------------------------------------------------------->
#_.extend Template.import,
#  showCreateImport: -> Session.get 'showCreateImport'
#  showAddImportDetail: -> Session.get 'showAddImportDetail'
#  showCreateProduct: -> Session.get 'showCreateProduct'
#  showOrder: -> Session.get 'showOrder'
#
#  showCurrentImport: -> Session.get 'currentImport'
#  showCurrentOrder: -> Session.get 'currentOrder'
#
#  events:
#    'click .create-import':     -> change('showCreateImport')
#    'click .add-import-detail': -> change('showAddImportDetail')
#    'click .create-product':    -> change('showCreateProduct')
#    'click .sale-product': -> change('showOrder')
#
## ---- showCreateImport  -------------------------------------------------------------->
#_.extend Template.createImport,
#  importCollection: Schema.imports.find({finish: false})
#  optionImport: -> return {}
#  events:
#    'click .createImport':  (event, template)-> insertImport(template)
#    'dblclick .reactive-table tr': ->
#      console.log @
#      Session.set 'currentImport', @
#      change('showAddImportDetail')
#
## ---- showAddImportDetail -------------------------------------------------------------------------------->
#_.extend Template.addImportDetail,
#  importDetailCollection: -> Schema.importDetails.find({import: (Session.get 'currentImport')._id})
#  optionImportDetail: -> return {
#  useFontAwesome: true
#  fields: [
#    { key: 'importQuality',     label: 'Số Lượng' }
#    { key: 'importPrice',       label: 'Giá' }
#    { key: '', label: 'Xóa', tmpl: Template.removeItem }
#  ]
#  }
#  currentProduct: {}
#  formatSearch: (item) -> "#{item.name} [#{item.skulls}]"
#
#  events:
#    'click .addImportDetail':   (event, template)-> insertImportDetail(template)
#
#    'click .finish': (event, template)->
#      insertImportDetails(template)
#      change('showCreateImport')
#      Session.set 'currentImport'
#
#    'dblclick .reactive-table tr': ->
#      Template.addImportDetail.currentProduct = Schema.products.findOne(@product)
#      Template.addImportDetail.ui.selectBox.select2 "val", Template.addImportDetail.currentProduct
##    'click .resetImportDetail': (event, template)-> resetImportDetail(template)
##    'click .removeItemTable': -> Schema.importDetails.remove(@_id)
#
#  rendered: ->
#    Template.addImportDetail.ui = {}
#    Template.addImportDetail.ui.selectBox = $(@find '.sl2')
#    $(@find '.sl2').select2
#      placeholder: 'chọn sản phẩm'
#      query: (query) -> query.callback
#        results: _.filter Template.addImportDetail.productList, (item) ->
#          item.name.indexOf(query.term) > -1 || item.productCode.indexOf(query.term) > -1
#        text: 'name'
#      initSelection: (element, callback) -> callback(Template.addImportDetail.currentProduct)
#      allowClear: true
#
#      id: '_id'
#      formatSelection: Template.addImportDetail.formatSearch
#      formatResult: Template.addImportDetail.formatSearch
#    .on "change", (e) ->
#      Template.addImportDetail.currentProduct = e.added
#    $(@find '.sl2').select2 "val", Template.addImportDetail.currentProduct
#
## ----Show-Product-------------------------------------------------------------------->
#_.extend Template.createProduct,
#  productCollection: Schema.products.find({})
#  events:
#    'click .createProduct': (event, template)->
#      console.log 'xx'
#      insertProduct(template)
#
#
## ----Show-Order--------------------------------------------------------------------->
#_.extend Template.createOrder,
#  orderCollection: Schema.orders.find({})
#  orderDetailCollection: Schema.orderDetails.find({})
#  currentOrderDetails: -> Session.get 'currentOrderDetails'
#
#
#
#  currentProduct: {}
#  formatSearch: (item) -> "#{item.name} [#{item.skulls}]"
#
#  events:
#  #-------Tao Moi Order----------------------------
#    'click .createOrder': (event, template)->
#      if checkValueOrder(template)
#        Schema.orders.insert
#          merchant      : root.currentMerchant._id
#          warehouse     : root.currentWarehouse._id
#          creator       : 'Sang'
#          seller        : template.find(".orderSeller").value
#          buyer         : template.find(".orderBuyer").value
#          orderCode     : template.find(".orderCode").value
#          deliveryType  : template.find(".orderDeliveryType").value
#          paymentMethod : template.find(".orderPaymentMethod").value
#          discountCash  : 0
#          productCount  : 0
#          saleCount     : 0
#          totalPrice    : 0
#          finalPrice    : 0
#          deposit       : 0
#          debit         : 0
#          billDiscount  : false
#          status        : 1
#      else
#        console.log 'sai thong tin'
#
#  #-------Chon Order------------------------------
#    'dblclick .order .reactive-table tr': -> Session.set 'currentOrder', @
#
#  #-------Tao OrderDetail--------------------------
#    'click .createOrderDetail': (event, template)->
#      if checkValueOrderDetail(template)
#        calculationOrderDetail(template, Session.get('currentOrder'))
#        addOrderDetail(template, Template.createOrder.currentOrderDetails())
#      else
#        console.log 'Sai thong tin'
#  #------Hoàn Thành Finish
#
#    'click .finishOrderDetail': (event, template)->
#      result = checkProductinStockQuality(Template.createOrder.currentOrderDetails(), Template.addImportDetail.productList)
#      if result.error then console.log result.error; return
#      createSaleAndSaleOrder(Session.get('currentOrder'), Session.get('currentOrderDetails'), template)
#
#  rendered: ->
#    Template.createOrder.ui = {}
#    Template.createOrder.ui.selectBox = $(@find '.sl2')
#    $(@find '.sl2').select2
#      placeholder: 'chọn sản phẩm'
#      query: (query) -> query.callback
#        results: _.filter Template.addImportDetail.productList, (item) ->
#          item.name.indexOf(query.term) > -1 || item.productCode.indexOf(query.term) > -1
#        text: 'name'
#      initSelection: (element, callback) -> callback(Template.createOrder.currentProduct)
#      allowClear: true
#
#      id: '_id'
#      formatSelection: Template.createOrder.formatSearch
#      formatResult: Template.createOrder.formatSearch
#    .on "change", (e) ->
#      Template.createOrder.currentProduct = e.added
#    $(@find '.sl2').select2 "val", Template.createOrder.currentProduct
#
#
#
#
##----------------------------------------------------------------------------------------------------->
#resetImportDetail = (template)->
#  template.find(".importQuality").value = 0
#  template.find(".importPrice").value = 0
#
#insertImport = (template)->
#  if template.find(".createImport-description").value
#    Schema.imports.insert
#      merchant: root.currentMerchant._id
#      warehouse: root.currentWarehouse._id
#      creator: 'sang'
#      description: template.find(".createImport-description").value
#      finish: false
#  else
#    console.log 'khong duoc de trong'
#
#insertProduct = (template)->
#  if checkValueProduct(template)
#    merchant = Merchant.findOne(root.currentMerchant._id)
#    merchant.addProduct
#      creator: 'Sang'
#      warehouse: root.currentWarehouse._id
#      name: template.find(".createProduct-name").value
#      productCode: template.find(".createProduct-productCode").value
#      skulls: [template.find(".createProduct-skull").value]
#      price: template.find(".createProduct-price").value
#  else
#    console.log 'Sai Thông Tin'
#
#insertImportDetail = (template)->
#  if chekValueImportDetail(template)
#    Schema.importDetails.insert
#      import: (Session.get 'currentImport')._id
#      product: Template.addImportDetail.currentProduct._id
#      importQuality: template.find(".importQuality").value
#      importPrice: template.find(".importPrice").value
#  else
#    console.log 'Sai Thong Tin'
#
#insertImportDetails = ->
#  currentImport = Import.findOne(Session.get('currentImport')._id)
#  currentImport.addImportDetails()
#
#checkValueProduct = (template)->
#  if template.find(".createProduct-name").value.length > 0 and
#    template.find(".createProduct-productCode").value.length > 0 and
#    template.find(".createProduct-skull").value.length > 0 and
#    template.find(".createProduct-price").value > 0
#    return true
#
#chekValueImportDetail = (template)->
#  if template.find(".importQuality").value > 0 and template.find(".importPrice").value > 0
#    return true
#
#change = (val)->
#  if val == 'showCreateImport'
#    if Session.get 'showCreateImport' then val = false else val = true
#    Session.set 'showCreateImport', val
#    Session.set 'showCreateProduct', false
#    Session.set 'showAddImportDetail', false
#    Session.set 'showOrder', false
#
#  if val == 'showCreateProduct'
#    if Session.get 'showCreateProduct' then val = false else val = true
#    Session.set 'showCreateImport', false
#    Session.set 'showCreateProduct', val
#    Session.set 'showAddImportDetail', false
#    Session.set 'showOrder', false
#
#  if val == 'showAddImportDetail'
#    if Session.get 'showAddImportDetail' then val = false else val = true
#    Session.set 'showCreateImport', false
#    Session.set 'showCreateProduct', false
#    Session.set 'showAddImportDetail', val
#    Session.set 'showSaleProduct', false
#
#  if val == 'showOrder'
#    if Session.get 'showOrder' then val = false else val = true
#    Session.set 'showCreateImport', false
#    Session.set 'showCreateProduct', false
#    Session.set 'showAddImportDetail', false
#    Session.set 'showOrder', val
#
##----ORDER---------------------------------------------------------------------------------->
#checkValueOrder= (template)->
#  if template.find(".orderSeller").value.length is 0 || template.find(".orderBuyer").value.length is 0 || template.find(".orderCode").value.length is 0
#    return false
#  else
#    return true
#
#calculation_tempOrder = (item, boolean)->
#  item.discountCash = calculation_item_range_min_max(item.discountCash, 0, item.totalPrice)
#  item.discountPercent = calculation_item_range_min_max(item.discountPercent, 0, 100)
#  if boolean
#    item.discountPercent = (item.discountCash/item.totalPrice)*100
#  else
#    item.discountCash = (item.discountPercent*item.totalPrice)/100
#  item.finalPrice = item.totalPrice - item.discountCash
##------ORDER_DETAILS----------------------------------------------------------------------------------------------------->
#checkValueOrderDetail=(template)->
#  currentProduct = Template.createOrder.currentProduct._id
#  if currentProduct and
#    template.find(".orderDetailPrice").value > 0 and
#    template.find(".orderDetailQuality").value > 0 and
#    template.find(".orderDetail-discountCash").value >= 0 and
#    template.find(".orderDetail-discountCash").value <= (template.find(".orderDetailPrice").value*template.find(".orderDetailQuality").value) and
#    template.find(".orderDetail-discountPercent").value >= 0 and
#    template.find(".orderDetail-discountPercent").value <= 100 and
#    template.find(".orderDetail-finalPrice").value >= 0
#  then return true
#  else
#    return false
#
#calculationOrderDetail = (template, currentOrder)->
#  if !template.find(".orderDetail-discountCash").value then template.find(".orderDetail-discountCash").value = 0
#  quality = template.find(".orderDetailQuality").value
#  price = template.find(".orderDetailPrice").value
#  totalPrice = quality*price
#  discountCash = template.find(".orderDetail-discountCash").value
#  if currentOrder.billDiscount
#    template.find(".orderDetail-discountCash").value = 0
#    template.find(".orderDetail-discountPercent").value = 0
#    template.find(".orderDetail-finalPrice").value = totalPrice
#  else
#    template.find(".orderDetail-discountPercent").value = discountCash/(totalPrice/100)
#    template.find(".orderDetail-finalPrice").value = totalPrice - discountCash
#
#addOrderDetail = (template, orderDetails) ->
#  temp = true
#  for detail in orderDetails
#    if Template.createOrder.currentProduct._id == detail.product
#      if parseFloat(template.find(".orderDetail-discountPercent").value) == detail.discountPercent
#        if parseInt(template.find(".orderDetailPrice").value) == detail.price
#          quality      = detail.quality + parseInt(template.find(".orderDetailQuality").value)
#          totalPrice   = quality * detail.price
#          discountCash = totalPrice*detail.discountPercent/100
#          finalPrice   = totalPrice - discountCash
#          Schema.orderDetails.update detail._id,
#            $set:
#              quality      : quality
#              discountCash : discountCash
#              finalPrice   : finalPrice
#          temp = false
#  if temp
#    Schema.orderDetails.insert
#      order               : Session.get('currentOrder')._id
#      product             : Template.createOrder.currentProduct._id
#      price               : template.find(".orderDetailPrice").value
#      quality             : template.find(".orderDetailQuality").value
#      discountCash        : template.find(".orderDetail-discountCash").value
#      discountPercent     : template.find(".orderDetail-discountPercent").value
#      tempDiscountPercent : template.find(".orderDetail-discountPercent").value
#      finalPrice          : template.find(".orderDetail-finalPrice").value
#
#
#
#
#
#
#  if _.findWhere(Session.get('currentOrderDetails'), {product: Template.createOrder.currentProduct._id}) then countProduct = 0 else countProduct = 1
#  saleProduct  = parseInt(template.find(".orderDetailQuality").value)
#  price        = parseInt(template.find(".orderDetailPrice").value)
#  discountCash = parseInt(template.find(".orderDetail-discountCash").value)
#  totalPrice   = saleProduct * price
#  finalPrice   = totalPrice - discountCash
#  Schema.orders.update Session.get('currentOrder')._id,
#    $inc:
#      productCount  : countProduct
#      saleCount     : saleProduct
#      discountCash  : discountCash
#      totalPrice    : totalPrice
#      finalPrice    : finalPrice
#
#  Session.set 'currentOrder', Schema.orders.findOne Session.get('currentOrder')._id
#
#checkProductinStockQuality= (orderDetailsList, productList)->
#  orderDetails = _.chain(orderDetailsList)
#  .groupBy("product")
#  .map (group, key) ->
#    return {
#    product: key
#    quality: _.reduce(group, ((res, current) -> res + current.quality), 0)
#    }
#  .value()
#  try
#    for currentDetail in orderDetails
#      currentProduct = _.findWhere(productList, {_id: currentDetail.product})
#      if currentProduct.availableQuality < currentDetail.quality
#        throw {message: "lỗi", item: currentDetail}
#
#    return {}
#  catch e
#    return {error: e}
#
#createSaleAndSaleOrder= (currentOrder, currentOrderDetails, template)->
#  order = Schema.orders.findOne currentOrder._id
#  sale = Schema.sales.insert
#    merchant      : order.merchant
#    warehouse     : order.warehouse
#    creator       : order.creator
#    seller        : order.seller
#    buyer         : order.buyer
#    orderCode     : order.orderCode
#    billDiscount  : order.billDiscount
#    productCount  : order.productCount
#    saleCount     : order.saleCount
#    deliveryType  : order.deliveryType
#    paymentMethod : order.paymentMethod
#    discountCash  : order.discountCash
#    totalPrice    : order.totalPrice
#    finalPrice    : order.finalPrice
#    deposit       : order.deposit
#    debit         : order.debit
#  #  , (e, r) -> console.log currentOrder
#
#  currentSale = Schema.sales.findOne(sale)
#  for currentOrderDetail in currentOrderDetails
#    productDetails = Schema.productDetails.find({product: currentOrderDetail.product}).fetch()
#    subtractQualityOnSales(productDetails, currentOrderDetail, currentSale)
#  if currentSale.deliveryType == 1
#    createDelivery(currentSale, template)
#  else
#    Schema.sales.update sale, $set: {status: true}
#  removeOrderAndOrderDetails(); Session.set 'currentOrder'
#
#
#subtractQualityOnSales= (stockingItems, sellingItem , currentSale) ->
#  transactionedQuality = 0
#  for product in stockingItems
#    requiredQuality = sellingItem.quality - transactionedQuality
#    if product.availableQuality > requiredQuality
#      takkenQuality = requiredQuality
#    else
#      takkenQuality = product.availableQuality
#    if currentSale.billDiscount
#      totalPrice = (takkenQuality * sellingItem.price)
#      if currentSale.discountCash == 0
#        discountPercent = 0
#      else
#        discountPercent = sale.discountCash/(currentSale.totalPrice/100)
#      discountCash = (discountPercent * totalPrice)/100
#      Schema.saleDetails.insert
#        sale: currentSale._id
#        product: sellingItem.product
#        productDetail: product._id
#        quality: takkenQuality
#        price: sellingItem.price
#        discountCash: discountCash
#        discountPercent: discountPercent
#        finalPrice: totalPrice - discountCash
#    else
#      totalPrice = (takkenQuality * sellingItem.price)
#      discountCash = (sellingItem.discountPercent * totalPrice)/100
#      Schema.saleDetails.insert
#        sale: currentSale._id
#        product: sellingItem.product
#        productDetail: product._id
#        quality: takkenQuality
#        price: sellingItem.price
#        discountCash: discountCash
#        discountPercent: sellingItem.discountPercent
#        finalPrice: totalPrice - discountCash
#
#    if currentSale.deliveryType == 0 then inStockQuality = takkenQuality else inStockQuality = 0
#    Schema.productDetails.update product._id,
#      $inc:
#        availableQuality: -takkenQuality
#        inStockQuality: -inStockQuality
#
#    Schema.products.update product.product,
#      $inc:
#        availableQuality: -takkenQuality
#        inStockQuality  : -inStockQuality
#
#    transactionedQuality += takkenQuality
#    if transactionedQuality == sellingItem.quality then break
#  return transactionedQuality == sellingItem.quality
#
#removeOrderAndOrderDetails= () ->
#  orderDetails = Session.get 'currentOrderDetails'
#  for detail in orderDetails
#    Schema.orderDetails.remove detail._id
#  Schema.orders.remove Session.get('currentOrder')._id
#
#
##----- DELIVERY-------------------------------------------
#
#
##checkValueDelivery=(template)->
##  delivery={}
##  delivery.contactName      : template.find(".delivery-contactName").value
##  delivery.deliveryAddress  : template.find(".delivery-contactAddress").value
##  delivery.contactPhone     : template.find(".delivery-contactPhone").value
##  delivery.deliveryDate     : template.find(".delivery-deliveryDate").value
##  delivery.comment          : template.find(".delivery-comment").value
##  delivery.transportationFee: template.find(".delivery-transportationFee").value
#
#createDelivery=(currentSale, template)->
#  Schema.deliveries.insert
#    merchant          : currentSale.merchant
#    warehouse         : currentSale.warehouse
#    creator           : currentSale.creator
#    sale              : currentSale._id
#    deliveryAddress   : template.find(".delivery-contactAddress").value
#    contactName       : template.find(".delivery-contactName").value
#    contactPhone      : template.find(".delivery-contactPhone").value
#    deliveryDate      : new Date
#    comment           : template.find(".delivery-comment").value
#    transportationFee : template.find(".delivery-transportationFee").value
#    status            : 0
#  , (error, result) -> console.log error
#
#
##updateMetroSummary= ->
##  Schema.metroSummaries.update {warehouse: @data.warehouse},
##    $inc:
##      stockCount: -@data.saleCount
##      saleCount: @data.saleCount
##      saleCountDay: @data.saleCount
##      saleCountMonth: @data.saleCount
##      revenue: @data.finalPrice
##      revenueDay: @data.finalPrice
##      revenueMonth: @data.finalPrice
##  , (error, result) -> console.log result; console.log error if error
#
#calculation_max_sale_product = (product, productlist)->
#  temp = 0
#  for item in productlist
#    if item.product == product._id then temp += item.quality
#  temp = product.availableQuality - temp
#  return temp
#
#
##
##
##
##
##recalculation_tempOrder =(item) ->
##  item.totalPrice = 0
##  for product in me.tempOrderDetails
##    item.totalPrice += product.quality * product.price
##  item.discountCash = (item.discountPercent * item.totalPrice)/100
##  item.finalPrice = item.totalPrice - item.discountCash
##----------------------------------------------------------------------------------------------------------->