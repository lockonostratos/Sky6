Sky.template.extends Template.accountingManagerThumbnail,
  buyerName: -> Schema.customers.findOne(@buyer)?.name
  sellerName: -> Schema.userProfiles.findOne(@seller)?.fullName
  formatNumber: (number) -> accounting.formatNumber(number)

  showInput: ->
    if @status == false and @submitted == @exported == @imported == @received == true and (@paymentsDelivery != 0 || @paymentsDelivery != 1) then return "display: none"
    if @status == @success == @received == @exported == false and @submitted ==  @imported == true and @paymentsDelivery != 1 then return "display: none"

  showInputText: ->
    if @status == true and @submitted == @exported == @imported == @received == false and (@paymentsDelivery == 0 || @paymentsDelivery == 1)
      return 'Đã Nhận Tiền'
    if @status == @success == @received == @exported == true and @submitted ==  @imported == false and @paymentsDelivery == 1
      return 'Đã Nhận Tiền'

  events:
    "click .confirmReceive": -> Sale.findOne(@_id).confirmReceiveSale()