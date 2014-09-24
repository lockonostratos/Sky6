Sky.template.extends Template.billThumbnail,
  buyerName: -> Schema.customers.findOne(@buyer).name
  sellerName: -> Schema.userProfiles.findOne(@seller).fullName
  formatNumber: (number) -> accounting.formatNumber(number)
  events:
    "dblclick .full-desc.trash": ->
