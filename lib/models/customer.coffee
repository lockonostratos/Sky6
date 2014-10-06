Schema.add 'customers', class Customer
  destroy: ->
    sale = Schema.sale.findOne({buyer: @id})
    if !sale then Schema.customers.remove(@id)