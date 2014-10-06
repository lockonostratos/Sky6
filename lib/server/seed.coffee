Meteor.startup ->
  return
  guest    = Accounts.createUser(email: 'dungthu@gera.vn'    , password: '12345')
  mer_VTNN = Merchant.create { name: 'Vật Tư Nông Nghiệp', creator: guest }
  mer_VTNN = Merchant.findOne mer_VTNN
  war_VTNN = mer_VTNN.addWarehouse { name: 'Kho Chính', creator: guest, isRoot : true, checkingInventory: false}
  Schema.userProfiles.insert
    user: guest
    isRoot: true
    fullName: "tài khoản dùng thử"
    parentMerchant: mer_VTNN
    currentMerchant: mer_VTNN
    currentWarehouse: war_VTNN
    systemVersion: '0.7.1'

  resetDatabase()
  if Schema.merchants.find().count() is 0
    version = '0.7.1'
    Schema.systems.insert({version: version})
    son     = Accounts.createUser(email: 'lehaoson@gera.vn'    , password: '12345')
    ky      = Accounts.createUser(email: 'hongky@gera.vn'      , password: '12345')
    loc     = Accounts.createUser(email: 'quocloc@gera.vn'     , password: '12345')
    quyen   = Accounts.createUser(email: 'phuongquyen@gera.vn' , password: '12345')
    trinh   = Accounts.createUser(email: 'phuongtrinh@gera.vn' , password: '12345')
    trong   = Accounts.createUser(email: 'ductrong@gera.vn'    , password: '12345')
    tester  = Accounts.createUser(email: 'tester@gera.vn'      , password: '12345')

    euroWindowId = Merchant.create { name: 'Euro Windows', creator: son }

    huynhChauId = Merchant.create { name: 'Huynh Chau', creator: son }
    merchant = Merchant.findOne huynhChauId
    warehouse = merchant.addWarehouse { name: 'Kho Chính', creator: son, isRoot : true, checkingInventory: false}
    warehouse2 = merchant.addWarehouse { name: 'Kho Phu', creator: son, isRoot : false, checkingInventory: false}

    hanoi = merchant.addBranch { name: 'Huynh Chau HA NOI', creator: son}
    merchant2 = Merchant.findOne hanoi
    warehouse3 = merchant2.addWarehouse { name: 'Kho Chính', creator: son, isRoot : true, checkingInventory: false}

    cloudProfile = Schema.userProfiles.insert
      user: son
      isRoot: true
      fullName: "Lê Ngọc Sơn"
      parentMerchant: huynhChauId
      currentMerchant: huynhChauId
      currentWarehouse: warehouse
      systemVersion: version

    kyProfile = Schema.userProfiles.insert
      user: ky
      creator: son
      isRoot: false
      fullName: "Nguyễn Hồng Kỳ"
      parentMerchant: huynhChauId
      currentMerchant: huynhChauId
      currentWarehouse: warehouse
      systemVersion: version

    locProfile = Schema.userProfiles.insert
      user: loc
      creator: son
      isRoot: false
      fullName: "Nguyễn Quốc Lộc"
      parentMerchant: huynhChauId
      currentMerchant: huynhChauId
      currentWarehouse: warehouse
      systemVersion: version

    quyenProfile = Schema.userProfiles.insert
      user: quyen
      creator: son
      isRoot: false
      fullName: "Đỗ Phượng Quyên"
      parentMerchant: huynhChauId
      currentMerchant: huynhChauId
      currentWarehouse: warehouse
      systemVersion: version
    trinhProfile = Schema.userProfiles.insert
      user: trinh
      creator: son
      isRoot: false
      fullName: "Angola Phương Trinh"
      parentMerchant: huynhChauId
      currentMerchant: huynhChauId
      currentWarehouse: warehouse
      systemVersion: version

    trongProfile = Schema.userProfiles.insert
      user: trong
      creator: son
      isRoot: false
      fullName: "Lê Đức Trọng"
      parentMerchant: huynhChauId
      currentMerchant: huynhChauId
      currentWarehouse: warehouse
      systemVersion: version

    testerProfile = Schema.userProfiles.insert
      user: tester
      creator: son
      isRoot: false
      fullName: "tester"
      parentMerchant: huynhChauId
      currentMerchant: huynhChauId
      currentWarehouse: warehouse
      systemVersion: version

    merchant.addCustomer({
      creator: son
      name: 'Lê Ngọc Sơn'
      phone: '0123456789012'
      address: '141334 - Lê Thị Riêng, P.13, Q.4, Tp.HCM'
    })

    merchant.addCustomer({
      creator: son
      name: 'Nguyễn Hồng Kỳ'
      phone: '01123456789'
      address: '42334 - Lê Thị Riêng, P.13, Q.4, Tp.HCM'
    })

    merchant.addCustomer({
      creator: son
      name: 'Nguyễn Quốc Lộc'
      phone: '0123456789'
      address: '45324 - Lê Thị Riêng, P.13, Q.4, Tp.HCM'
    })

    merchant.addCustomer({
      creator: son
      name: 'Lê Thị Thảo Nhi'
      phone: '0123456789'
      address: '1234 - Lê Thị Riêng, P.13, Q.4, Tp.HCM'
    })

    seedSystemRoles()
    seedProvidersFor merchant, son
    seedSkullsFor merchant, son
    seedProductsFor merchant, son, warehouse

resetDatabase = ->
  Meteor.users.remove({})
  Schema.userProfiles.remove({})
  Schema.roles.remove({})
  Schema.messages.remove({})

  Schema.merchants.remove({})
  Schema.warehouses.remove({})
  Schema.customers.remove({})
  Schema.providers.remove({})
  Schema.skulls.remove({})
  Schema.products.remove({})
  Schema.productDetails.remove({})
  Schema.productLosts.remove({})

  Schema.imports.remove({})
  Schema.importDetails.remove({})
  Schema.orders.remove({})
  Schema.orderDetails.remove({})
  Schema.sales.remove({})
  Schema.saleDetails.remove({})
  Schema.deliveries.remove({})
  Schema.inventories.remove({})
  Schema.inventoryDetails.remove({})
  Schema.returns.remove({})
  Schema.returnDetails.remove({})


  Schema.transactions.remove({})
  Schema.transactionDetails.remove({})




seedSystemRoles = ->
  Schema.roles.insert
    group: 'merchant'
    name: 'admin'
    description: 'ADMIN'
    permissions: [Sky.system.merchantPermissions.su.key]

  Schema.roles.insert
    group: 'merchant'
    name: 'salesBasic'
    description: 'BÁN HÀNG'
    permissions: [Sky.system.merchantPermissions.sales.key]

  Schema.roles.insert
    group: 'merchant'
    name: 'salesManager'
    description: 'QUẢN LÝ BÁN HÀNG'
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
    emailCreator: Meteor.users.findOne(creator).emails[0].address
    description: "Nhập tồn đầu kỳ 2014"
    warehouse: warehouse
    totalPrice: 0
    deposit: 0
    debit: 0
    finish: true
    submited: true
  }, importDetails



