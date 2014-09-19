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



