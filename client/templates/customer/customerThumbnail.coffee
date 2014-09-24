Sky.template.extends Template.customerThumbnail,
  events:
    "dblclick .full-desc.trash": ->
      Schema.customers.remove(@_id)