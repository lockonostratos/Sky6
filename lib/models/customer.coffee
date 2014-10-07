Schema.add 'customers', class Customer
  destroy: ->
    sale = Schema.sales.findOne({buyer: @id})
    if !sale then Schema.customers.remove(@id)