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

  updateDelivery: (success = true) ->
    unless sale = Schema.sales.findOne(@data.sale) then return 'Phiếu Bán Hàng Không Có Giao Hàng'
    if sale.status == sale.submitted == true then return 'Phiếu Bán Hàng Đã Hoàn Thành, Không Thể Giao Hàng'
    switch @data.status
      when 1
        deliveryOption = {status: 2, shipper: Meteor.userId()}
        saleOption     = {status: true}
      when 3
        deliveryOption = {status: 4, shipper: Meteor.userId()}
      when 4
        #thanh cong
        if success
          if sale.debit > 0
            deliveryOption = {status: 5, shipper: Meteor.userId()}
            saleOption     = {status: true, success: true}
          else
            deliveryOption = {status: 5, shipper: Meteor.userId()}
            saleOption     = {status: true, success: true}
        #that bai
        else
          if sale.debit > 0
            deliveryOption = {status: 8, shipper: Meteor.userId()}
            saleOption     = {status: true, success: false}
          else
            deliveryOption = {status: 8, shipper: Meteor.userId()}
            saleOption     = {status: true, success: false}
      #xac nhan thanh cong
      when 6
        console.log 'asdasd'
        deliveryOption = {status: 7, shipper: Meteor.userId()}
        saleOption     = {status: true, submitted: true}
      #xac nhan that bai
      when 9
        deliveryOption = {status: 10, shipper: Meteor.userId()}
        saleOption     = {status: true, submitted: true}

    console.log @data.status
    Schema.deliveries.update @id, $set: deliveryOption
    Schema.sales.update @data.sale, $set: saleOption