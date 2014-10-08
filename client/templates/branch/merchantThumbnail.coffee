Sky.template.extends Template.merchantThumbnail,
  isntRoot: -> Session.get('currentProfile')?.parentMerchant isnt @_id
  events:
    "dblclick .full-desc.trash": ->
      Schema.merchants.remove(@_id)
      for item in Schema.warehouses.find({merchant: @_id}).fetch()
        Schema.warehouses.remove item._id