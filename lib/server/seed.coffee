Meteor.startup ->
  return
  resetDatabase()
  if Schema.merchants.find().count() is 0
    creator = Accounts.createUser(email: 'lehaoson@gmail.com', password: 'Ultimate5')
    ky = Accounts.createUser(email: 'nguyenhongky@gmail.com', password: 'Ultimate5')
    loc = Accounts.createUser(email: 'nguyenquocloc@gmail.com', password: 'Ultimate5')

    euroWindowId = Merchant.create { name: 'Euro Windows', creator: creator }

    huynhChauId = Merchant.create { name: 'Huynh Chau', creator: creator }
    merchant = Merchant.findOne huynhChauId
    warehouse = merchant.addWarehouse { name: 'Kho Chính', creator: creator }
    warehouse2 = merchant.addWarehouse { name: 'Kho Phu', creator: creator }

    hanoi = merchant.addBranch { name: 'Huynh Chau HA NOI', creator: creator }
    merchant2 = Merchant.findOne hanoi
    warehouse3 = merchant2.addWarehouse { name: 'Kho Chính', creator: creator }

    Meteor.users.update(creator, $set:{profile: {isRoot: true, parent:huynhChauId, merchant: huynhChauId, warehouse: warehouse}})
    Meteor.users.update(loc, $set:{profile: {isRoot: false, parent:huynhChauId, merchant: huynhChauId, warehouse: warehouse2, creator: creator}})
    Meteor.users.update(ky, $set:{profile: {isRoot: false, parent:huynhChauId, merchant: hanoi, warehouse: warehouse3, creator: creator}})

    merchant.addCustomer({creator: creator, name: 'Lê Ngọc Sơn', phone: '01223456789'})
    merchant.addCustomer({creator: creator, name: 'Nguyễn Hồng Kỳ', phone: '01123456789'})
    merchant.addCustomer({creator: creator, name: 'Nguyễn Quốc Lộc', phone: '0123456789'})
    merchant.addCustomer({creator: creator, name: 'Lê Thị Thảo Nh', phone: '0123456789'})


    seedSystemRoles()
    seedProvidersFor merchant, creator
    seedSkullsFor merchant, creator
    seedProductsFor merchant, creator, warehouse

resetDatabase = ->
  Meteor.users.remove({})
  Schema.customers.remove({})
  Schema.roles.remove({})
  Schema.merchants.remove({})
  Schema.warehouses.remove({})
  Schema.providers.remove({})
  Schema.skulls.remove({})
  Schema.imports.remove({})
  Schema.importDetails.remove({})
  Schema.products.remove({})
  Schema.productDetails.remove({})
  Schema.orders.remove({})
  Schema.orderDetails.remove({})
  Schema.sales.remove({})
  Schema.saleDetails.remove({})

seedSystemRoles = ->
  Schema.roles.insert
    group: 'merchant'
    name: 'admin'
    description: 'admin'
    permissions: [Sky.system.merchantPermissions.su.key]

  Schema.roles.insert
    group: 'merchant'
    name: 'salesBasic'
    description: 'bán hàng'
    permissions: [Sky.system.merchantPermissions.sales.key]

  Schema.roles.insert
    group: 'merchant'
    name: 'salesManager'
    description: 'quản lý bán hàng'
    permissions: [
      Sky.system.merchantPermissions.sales.key
      Sky.system.merchantPermissions.returns.key
    ]

seedAccountsFor = (merchant) ->
  merchant.addAccount

seedProvidersFor = (merchant, creator) ->
  providers = [
    "BP"
    "CASTROL"
    "HONDA"
    "YAMAHA"
    "SYM"
    "SUZUKI"
    "SHELL ADVANCE"
    "VILUBE"
    "INDO - PETROL"
    "THÁI ECO"
    "MOTUL"
    "OGAWA"
    "CALTEX"
    "NIKKO"
    "SPECTROL"
    "MEKONG"
    "SHIP OIL"
  ]
  merchant.addProvider { name: "DẦU NHỚT #{provider}", creator: creator , status: false} for provider in providers

seedSkullsFor = (merchant, creator) ->
  skulls = [
    "QUI CÁCH"
    "ĐƠN VỊ TÍNH"
  ]
  merchant.addSkull { name: skull, creator: creator } for skull in skulls

seedProductsFor = (merchant, creator, warehouse) ->


  childPro = merchant.addProduct
    creator: creator
    warehouse: warehouse
    name: "Advance SX2"
    productCode: "1234567890123"
    skulls: ["1L", "CHAI"]
    price: 725000

  pro = merchant.addProduct
    creator: creator
    warehouse: warehouse
    name: "Advance SX2"
    productCode: "123456789003"
    skulls: ["1L", "THÙNG"]
    childProduct: {product: childPro, quality: 20}
    price: 1400000

  products = [
    { name: "Helix HX3", productCode: "123456789002", skulls: ["12L", "CHAI"], price: 63000 }
    { name: "Helix HX3", productCode: "123456789003", skulls: ["9L", "CHAI"], price: 543000 }
    { name: "Helix Ultra", productCode: "123456789004", skulls: ["4L", "CHAI"], price: 63000 }
    { name: "Helix Diesel HX5", productCode: "123456789005", skulls: ["6L", "CHAI"], price: 424000 }
    { name: "Rimula R1", productCode: "123456789006", skulls: ["209L", "THÙNG"], price: 10287000 }
    { name: "Gadus S2 V100", productCode: "123456789007", skulls: ["180K", "THÙNG"], price: 18219000 }
    { name: "Tellus S2 M100", productCode: "123456789008", skulls: ["209L", "THÙNG"], price: 18219000 }
    { name: "DẦU NHỚT VIỆT NAM M02", productCode: "123456789009", skulls: ["209L", "THÙNG"], price: 18219000 }
  ]

  importDetails = []
  for product in products
    product.creator = creator
    product.warehouse = warehouse
    id = merchant.addProduct product

    importDetails.push
      product: id
      importQuality: 100
      importPrice: product.price

  importDetails.push
    product: pro
    importQuality: 100
    importPrice: 1200000

  importDetails.push
    product: pro
    importQuality: 50
    importPrice: 1000000

  imprt = merchant.import {
    creator: creator
    description: "Nhập tồn đầu kỳ 2014"
    warehouse: warehouse
    finish: true
  }, importDetails

  tempImprt = Schema.imports.insert
    creator: creator
    description: "Nhập tạm 2014"
    merchant: merchant.id
    warehouse: warehouse
    finish: false

  tempPro = Schema.products.findOne({})

  Schema.importDetails.insert
    import: tempImprt
    product: tempPro._id
    importQuality: 20
    importPrice: 5000





