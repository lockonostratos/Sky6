Sky.template.extends Template.deliveryThumbnail,
  colorClasses: 'none'
  showStatus: (status) ->
    switch status
      when 1 then 'Chưa được nhận '
      when 2 then 'Chờ xác nhận kho'
      when 3 then 'Đã xác nhận xuất kho'
      when 4 then 'Đang Giao Hàng'
      when 5 then 'Giao Thàng Công'
      when 6 then 'Kế Toán Đã Nhận Tiền'
      when 7 then 'Kết Thúc'
      when 8 then 'Giao Thất Bại'
      when 9 then 'Kho Đã Nhận Hàng'
      when 10 then 'Hoàn Tất'

  buttonSuccessText: (status) ->
    switch status
      when 1 then 'nhận đơn giao hàng'
      when 3 then 'xác nhận đi giao hàng'
      when 4 then 'Thành Công'
      when 5 then 'Chờ Xác Nhận Của Kế Toán'
      when 6 then 'Xác Nhận'
      when 8 then 'Chờ Xác Nhân Của Kho'
      when 9 then 'Xác Nhận'

  buttonUnSuccessText: (status) -> 'Thất Bại' if status == 4
  hideButtonSuccess: (status)-> return "display: none" if _.contains([2,5,7,8,10],status)
  hideButtonUnSuccess: (status)-> return "display: none" unless status == 4

  events:
    "click .successDelivery":   -> Delivery.findOne(@_id).updateDelivery(true)
    "click .unSuccessDelivery": -> Delivery.findOne(@_id).updateDelivery(false)
