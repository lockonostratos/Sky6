Sky.template.extends Template.billExportThumbnail,
  buyerName: -> Schema.customers.findOne(@buyer)?.name
  sellerName: -> Schema.userProfiles.findOne(@seller)?.fullName
  formatNumber: (number) -> accounting.formatNumber(number)

  showInput: ->
    if @status == @received == false and @submitted == @exported == @imported == true and @paymentsDelivery != 0 then return "display: none"
    if @status == @received == false and @submitted == @exported == @imported == true and @paymentsDelivery != 1 then return "display: none"
    if @status == @received == @exported == false and @submitted == @imported == true and @paymentsDelivery != 1 then return "display: none"

  showInputText: ->
    if @status == @received == true and @submitted == @exported == @imported == false and @paymentsDelivery == 0 then return 'Xuất Bán Hàng'
    if @status == @received == true and @submitted == @exported == @imported == false and @paymentsDelivery == 1 then return 'Xuất Giao Hàng'
    if @status == @received == @exported == true and @submitted == @imported == false and @paymentsDelivery == 1 then return 'Đã Nhận Hàng'

  events:
    "click .creatSaleExport": ->  Sale.findOne(@_id).createSaleExport()