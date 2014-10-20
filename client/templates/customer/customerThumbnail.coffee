Sky.template.extends Template.customerThumbnail,
  gender: -> if @gender then 'Nam' else 'Nữ'
  isntDelete: -> unless Schema.sales.findOne({buyer: @_id}) then true
  dateOfBirth: -> @dateOfBirth?.toDateString()
  events:
    "dblclick .full-desc.trash": -> Customer.findOne(@_id).destroy()