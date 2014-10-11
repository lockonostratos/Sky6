Schema.add 'deliveries', class Delivery
  @newBySale: (saleId, orderId)->
    sale = Schema.sales.findOne(saleId)
    order = Schema.orders.findOne(orderId)
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
    option

  @updateDelivery: (deliveryId, success = true) ->
    return 'Bạn Chưa Đăng Nhập' if !userProfile = Sky.global.userProfile()
    return 'Phiếu Giao Hàng Không Chính Xác' if !delivery = Schema.deliveries.findOne(deliveryId)
    return 'Phiếu Bán Hàng Không Có Giao Hàng' if !sale = Schema.sales.findOne(delivery: deliveryId)
    return 'Phiếu Bán Hàng Đã Hoàn Thành, Không Thể Giao Hàng' if sale.status == true || sale.success == true

    switch delivery.status
      when 0
        Schema.deliveries.update deliveryId, $set:{status: 1, shipper: Meteor.userId()}
        Schema.sales.update sale._id, $set:{status: true}
#      when 1
#        saleDetails = Schema.saleDetails.find(sale: sale._id).fetch()
#        for detail in saleDetails
#          Schema.productDetails.update detail.productDetail, $inc: {instockQuality  : -detail.quality}
#          Schema.products.update detail.product, $inc: {instockQuality  : -detail.quality}
#        Schema.deliveries.update deliveryId, $set:{status: 2, exporter: Meteor.userId()}
      when 2
        Schema.deliveries.update deliveryId, $set:{status: 3, shipper: Meteor.userId()}

      when 3
        if success
          Schema.deliveries.update deliveryId, $set:{status: 4, shipper: Meteor.userId()}
        else
          Schema.deliveries.update deliveryId, $set:{status: 7, shipper: Meteor.userId()}
          Schema.sales.update sale._id, $set:{status: true}

      #xac nhan cua ke toan
      when 4
        Schema.deliveries.update deliveryId, $set:{status: 5, cashier: Meteor.userId()}
        Schema.sales.update sale._id, $set:{status: true, success: true, paymentsDelivery: sale.debit, debit: 0}

      when 5
        Schema.deliveries.update deliveryId, $set:{status: 6, shipper: Meteor.userId()}
        Schema.sales.update sale._id, $set:{status: true, success: true}

#      when 7
#        saleDetails = Schema.saleDetails.find(sale: sale._id).fetch()
#        for detail in saleDetails
#          option =
#            availableQuality: detail.quality
#            instockQuality  : detail.quality
#          Schema.productDetails.update detail.productDetail, $inc: option
#          Schema.products.update detail.product, $inc: option
#        Schema.deliveries.update deliveryId, $set:{status: 8, importer: Meteor.userId()}
      when 8
        Schema.deliveries.update deliveryId, $set:{status: 9, shipper: Meteor.userId()}
        Schema.sales.update sale._id, $set:{status: true, success: false}
