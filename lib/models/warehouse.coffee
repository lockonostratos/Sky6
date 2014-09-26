Schema.add 'warehouses', class Warehouse
  @newBy:->

  addNewOrder: (option) ->
    option.merchant     = @data.merchant
    option.warehouse    = @id
    option.discountCash = 0
    option.productCount = 0
    option.saleCount    = 0
    option.totalPrice   = 0
    option.finalPrice   = 0
    option.deposit      = 0
    option.debit        = 0
    option.status       = 0
    option.checkingInventory  = false
    Schema.orders.insert option, (error, result)->
      console.log result; console.log error if error

  addImport: (option) ->
    return ('Mô Tả Không Được Đễ Trống') if !option.description
    option.merchant   = @data.merchant
    option.warehouse  = @id
    option.creator    = Meteor.userId()
    option.finish     = false
    Schema.imports.insert option, (error, result)-> console.log result; console.log error if error

