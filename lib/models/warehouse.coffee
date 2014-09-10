Schema.add 'warehouses', class Warehouse
  addNewOrder: (option) ->
    option.merchant     = @data.merchant
    option.warehouse    = @id
    option.discountCash = 0
    option.productCount = 0
    option.saleCount    = 0
    option.totalPrice   = 0
    option.finalPrice   = 0
    option.deposit      = 0
    option.debit        = 0
    option.status       = 0
    Schema.orders.insert option, (error, result)->
      console.log result; console.log error if error

  updateDelivery: (delivery_id, status)->
    item = Schema.deliveries.findOne(delivery._id)
    if item.status == 0 and status == 0
      Schema.deliveries.update item._id, $set:{status: 1, shipper: Meteor.userId()}; return
    if item.status == 1 and status == 0
      Schema.deliveries.update item._id, $set:{status: 2, exporter: Meteor.userId()}; return
    if item.status == 2 and status == 0
      Schema.deliveries.update item._id, $set:{status: 3}; return

    #Giao Hang Thanh Cong
    if item.status == 3 and status == 1
      Schema.deliveries.update item._id, $set:{status: 4}; return
    if item.status == 4 and status == 0
      Schema.deliveries.update item._id, $set:{status: 5, cashier: Meteor.userId()}; return
    if item.status == 5 and status == 0 then updateDeliveryTrue item

    #Giao Hang That Bai
    if item.status == 3 and status == 2
      Schema.deliveries.update item._id, $set:{status: 7}; return
    if item.status == 7 and status == 0
      Schema.deliveries.update item._id, $set:{status: 8, importer: Meteor.userId()}; return
    if item.status == 8 and status == 0
      Schema.deliveries.update item._id, $set:{status: 9}
      updateDeliveryFalse item


updateDeliveryTrue= (item) ->
  saleDetails = Schema.saleDetails.find({sale: item.sale}).fetch()
  for saleDetail in saleDetails
    productDetail = Schema.productDetails.findOne(saleDetail.productDetail)
    Schema.productDetails.update saleDetail.productDetail, $inc: {instockQuality: -saleDetail.quality}
    Schema.products.update productDetail.product, $inc: {instockQuality: -saleDetail.quality}
  Schema.sales.update item.sale, $set:{status: true}
  Schema.deliveries.update item._id, $set:{status: 6}

updateDeliveryFalse= (item) ->
  saleDetails = Schema.saleDetails.find({sale: item.sale}).fetch()
  for saleDetail in saleDetails
    productDetail = Schema.productDetails.findOne(saleDetail.productDetail)
    Schema.productDetails.update saleDetail.productDetail, $inc: {availableQuality: saleDetail.quality}
    Schema.products.update productDetail.product, $inc: {availableQuality: saleDetail.quality}
  Schema.sales.update item.sale, $set:{status: false}
  Schema.deliveries.update item._id, $set:{status: 9}
