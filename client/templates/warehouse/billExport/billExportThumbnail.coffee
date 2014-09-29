Sky.template.extends Template.billExportThumbnail,
  buyerName: -> Schema.customers.findOne(@buyer)?.name
  sellerName: -> Schema.userProfiles.findOne(@seller)?.fullName
  formatNumber: (number) -> accounting.formatNumber(number)

  showInput: ->
    if @status == true and @paymentsDelivery == 0 and @success ==false
#      console.log @
    else
      return "display: none"
  events:
    "click .creatSaleExport": ->
      if @status == true and @paymentsDelivery == 0 and @success ==false
        Sale.findOne(@_id).createSaleExport()