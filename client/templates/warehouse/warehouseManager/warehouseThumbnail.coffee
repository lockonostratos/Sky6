Sky.template.extends Template.warehouseThumbnail,
  isntDelete: -> if !Schema.products.findOne({warehouse: @_id}) and @isRoot == false then true
  events:
    "dblclick .full-desc.trash": ->
      Schema.warehouses.remove(@_id)