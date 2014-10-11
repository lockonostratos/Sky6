Sky.template.extends Template.deliveryThumbnail,
  colorClasses: 'none'
  showStatus: (status) ->
    switch status
      when 0 then 'Chưa được nhận '
      when 2 then 'Đã xác nhận xuất kho'
      when 3 then 'Đang Giao Hàng'
      when 4 then 'Giao Thàng Công'
      when 5 then 'Kế Toán Đã Nhận Tiền'
      when 6 then 'Kết Thúc'
      when 7 then 'Giao Thất Bại'
      when 8 then 'Kho Đã Nhận Hàng'
      when 9 then 'Hoàn Tất'

  buttonSuccessText: (status) ->
    switch status
      when 0 then 'nhận đơn giao hàng'
      when 2 then 'xác nhận đi giao hàng'
      when 3 then 'Thành Công'
      when 4 then 'Chờ Xác Nhận Của Kế Toán'
      when 5 then 'Xác Nhận'
      when 7 then 'Chờ Xác Nhân Của Kho'
      when 8 then 'Xác Nhận'

  buttonUnSuccessText: (status) -> 'Thất Bại' if status == 3
  hideButtonSuccess: (status)-> return "display: none" if  status == 6 || status == 9 || status == 7 || status == 4
  hideButtonUnSuccess: (status)-> return "display: none" if status != 3

  events:
    "click .successDelivery": ->
      Delivery.updateDelivery(@_id, true)

    "click .unSuccessDelivery": ->
      Delivery.updateDelivery(@_id, false)
