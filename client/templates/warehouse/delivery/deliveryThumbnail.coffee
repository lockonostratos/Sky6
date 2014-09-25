Sky.template.extends Template.deliveryThumbnail,
  colorClasses: 'none'
  showStatus: (status) ->
    switch status
      when 0 then 'Chưa được nhận '
      when 1 then 'Chờ xuất kho'
      when 2 then 'Đã xác nhận xuất kho'
      when 3 then 'Đang Giao Hàng'
      when 4 then 'Giao Thàng Công'
      when 5 then 'Đã Nhận Tiền'
      when 6 then 'Kết Thúc'
      when 7 then 'Giao Thất Bại'
      when 8 then 'Đã Nhận Hàng'
      when 9 then 'Kết Thúc'

  buttonSuccessText: (status) ->
    switch status
      when 0 then 'nhận đơn giao hàng'
      when 1 then 'xác nhận xuất kho'
      when 2 then 'xác nhận đi giao hàng'
      when 3 then 'Thành Công'
      when 4 then 'Đã Nhận Tiền'
      when 5 then 'Xác Nhận'
      when 7 then 'Đã Nhập Kho'
      when 8 then 'Xác Nhận'

  buttonUnSuccessText: (status) -> 'Thất Bại' if status == 3
  hideButtonSuccess: (status)-> return "display: none" if  status == 6 || status == 9
  hideButtonUnSuccess: (status)-> return "display: none" if status != 3

  events:
    "dblclick .full-desc.trash": ->
      ReturnDetail.removeReturnDetail(@_id)

    "click .successDelivery": ->
      Delivery.updateDelivery(@_id, true)

    "click .unSuccessDelivery": ->
      Delivery.updateDelivery(@_id, false)
