Schema.add 'warehouses', class Warehouse
  @newDefault: (parentMerchantId = null, merchantId = null, creator = null )->
    merchant = Schema.merchants.findOne(merchantId)
    warehouse = Schema.warehouses.find({merchant: merchantId}).count()
    if merchant and !warehouse
      option =
        parentMerchant    : parentMerchantId ? merchant.parent
        merchant          : merchant._id
        creator           : creator ? Meteor.userId()
        name              : 'Kho Chính'
        isRoot            : false
        checkingInventory : false
      option.parentMerchant = merchant.parent if merchant.parent
      option

  @new: (merchantId)->
    merchant = Schema.merchants.findOne(merchantId)
    if merchant
      warehouseCount = Schema.warehouse.find({merchant: merchantId}).count()
      option =
        parentMerchant    : merchant.parent
        merchant          : merchant._id
        creator           : Meteor.userId()
        name              : "Kho Phu + #{warehouseCount}"
        isRoot            : false
        checkingInventory : false
      option.parentMerchant = merchant.parent if merchant.parent
      option

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

