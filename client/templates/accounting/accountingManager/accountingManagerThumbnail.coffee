checkAllow= (context)->
  if context.status == true and context.submitted == context.exported == context.imported == context.received == false and (context.paymentsDelivery == 0 || context.paymentsDelivery == 1)
    return true
  if context.status == context.success == context.received == context.exported == true and context.submitted ==  context.imported == false and context.paymentsDelivery == 1
    return true


Sky.template.extends Template.accountingManagerThumbnail,
  buyerName: -> Schema.customers.findOne(@buyer)?.name
  sellerName: -> Schema.userProfiles.findOne(@creator)?.fullName
  group: ->
    if @paymentsDelivery is 0 then return 'Phiếu Bán'
    if @paymentsDelivery is 1 then return 'Phiếu Giao'
  formatNumber: ->
    if @received and @exported
      number = @debit
    else
      number = @deposit
    accounting.formatMoney(number, { format: "%v", precision: 0 })




  showInput: -> if !checkAllow(@) then return "display: none"
  showInputText: -> if checkAllow(@) then return 'Đã Nhận Tiền'

  events:
    "click .confirmReceive": -> Sale.findOne(@_id).confirmReceiveSale()