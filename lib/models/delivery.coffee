Schema.add 'deliveries', class Delivery
  @createdNewBySale: (saleId, orderId)->
    sale = Schema.sales.findOne(saleId)
    order = Schema.orders.findOne(orderId)
    if sale.orderCode == order.orderCode
      option =
        merchant        : sale.merchant
        warehouse       : sale.warehouse
        creator         : Meteor.userId()
        sale            : sale._id
        contactName     : order.contactName
        contactPhone    : order.contactPhone
        deliveryAddress : order.deliveryAddress
        comment         : order.comment
        status          : 0
      option._id = Schema.deliveries.insert option
      option

  @updateDelivery: (deliveryId, success = true) ->
    return 'Bạn Chưa Đăng Nhập' if !userProfile = Sky.global.userProfile()
    return 'Phiếu Giao Hàng Không Chính Xác' if !delivery = Schema.deliveries.findOne(deliveryId)

    switch delivery.status
      when 0
        Schema.deliveries.update deliveryId, $set:{status: 1, shipper: Meteor.userId()}
      when 1
        Schema.deliveries.update deliveryId, $set:{status: 2, exporter: Meteor.userId()}
      when 2
        Schema.deliveries.update deliveryId, $set:{status: 3}
      when 3
        if success
          Schema.deliveries.update deliveryId, $set:{status: 4}
        else
          Schema.deliveries.update deliveryId, $set:{status: 7}
      when 4
        Schema.deliveries.update deliveryId, $set:{status: 5, cashier: Meteor.userId()}
      when 5
        Schema.deliveries.update deliveryId, $set:{status: 6}

      when 7
        Schema.deliveries.update deliveryId, $set:{status: 8, importer: Meteor.userId()}
      when 8
        Schema.deliveries.update deliveryId, $set:{status: 9}



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



