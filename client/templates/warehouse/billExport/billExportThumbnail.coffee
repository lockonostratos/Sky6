Sky.template.extends Template.billExportThumbnail,
  buyerName: -> Schema.customers.findOne(@buyer)?.name
  sellerName: -> Schema.userProfiles.findOne(@seller)?.fullName
  formatNumber: (number) -> accounting.formatNumber(number)

  showInput: ->
    unless @status == true  and @success ==false and (@paymentsDelivery == 0 || @paymentsDelivery == 1)
      return "display: none"

  showInputText: ->
    if @status == true and @success == @export == @import == false and @paymentsDelivery == 0 then return 'Xuất Bán Hàng'
    if @status == true and @success == @export == @import == false and @paymentsDelivery == 1 then return 'Xuất Giao Hàng'
    if @status == @export == true and @success == @import == false and @paymentsDelivery == 1 then return 'Nhận Giao Hàng'

  events:
    "click .creatSaleExport": ->  Sale.findOne(@_id).createSaleExport()