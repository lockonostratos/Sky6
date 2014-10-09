Sky.template.extends Template.billThumbnail,
  isntDelete: -> if @status == true and @success == false then true else false
  buyerName: -> Schema.customers.findOne(@buyer)?.name
  sellerName: -> Schema.userProfiles.findOne(@seller)?.fullName
  formatNumber: (number) -> accounting.formatNumber(number)
  events:
    "dblclick .full-desc.trash": ->