Sky.template.extends Template.warehouseThumbnail,
  isntRoot: -> Session.get('currentProfile').parentMerchant isnt @_id
  events:
    "dblclick .full-desc.trash": ->
      Schema.merchants.remove(@_id)