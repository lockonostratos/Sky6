userProfile = -> Schema.userProfiles.findOne({user: Meteor.userId()})
Schema.add 'notifications', class Notification
  @send: (message, receiver, notificationType = Sky.notificationTypes.notify.key) ->
    newNotification = {
      sender: Meteor.userId()
      receiver: receiver
      message: message
      notificationType: notificationType
    }
    @schema.insert newNotification

  @permissionChanged: (permission) ->
    if permission
      userProfile = Schema.userProfiles.findOne({user: Meteor.userId()})
      creatorName = userProfile.fullName ? Meteor.user().emails[0].address
      for receiver in Schema.userProfiles.find({parentMerchant: userProfile.parentMerchant, roles: {$elemMatch: {$in:[permission.name]}}}).fetch()
        @send(NotificationMessages.permissionChanged(creatorName), receiver.user) unless userProfile.user is receiver.user

  @newMemberJoined: (newMemberName, companyName) ->
    if newMemberName && companyName
      userProfile = Schema.userProfiles.findOne({user: Meteor.userId()})
      for receiver in Schema.userProfiles.find({parentMerchant: userProfile.parentMerchant}).fetch()
        unless receiver.user is userProfile.user
          @send(NotificationMessages.newMemberJoined(newMemberName, companyName), receiver.user) unless userProfile.user is receiver.user

  @newSaleDefault: (saleId) ->
    unless saleId then return
    userProfile = Schema.userProfiles.findOne({user: Meteor.userId()})
    sale = Schema.sales.findOne({_id: saleId, creator: userProfile.user})
    if sale
      creatorName = userProfile.fullName ? Meteor.user().emails[0].address
      @send(NotificationMessages.saleHelper(creatorName, sale.orderCode, sale.finalPrice), sale.seller) unless sale.creator is sale.seller
      for receiver in Schema.userProfiles.find({parentMerchant: userProfile.parentMerchant, roles: {$elemMatch: {$in:Role.rolesOf(Sky.system.merchantPermissions.cashierSale.key)}}}).fetch()
        @send(NotificationMessages.accountingNotify(creatorName, sale.orderCode), receiver.user) unless userProfile.user is receiver.user

#Ke toan
  @newSaleAccountingConfirm: (sale) ->
    unless sale then return
    userProfile = Schema.userProfiles.findOne({user: Meteor.userId()})
    unless sale.merchant is userProfile.currentMerchant then return
    unless Role.hasPermission(userProfile._id, Sky.system.merchantPermissions.cashierSale.key) then return

    if sale.received == sale.imported ==  sale.exported == sale.submitted == false and sale.status == true
      cashierName = userProfile.fullName ? Meteor.user().emails[0].address
      creatorName = (Schema.userProfiles.findOne({user: sale.creator})).fullName ? Meteor.users.findOne(sale.creator).emails[0].address
      sellerName  = (Schema.userProfiles.findOne({user: sale.seller})).fullName ? Meteor.users.findOne(sale.seller).emails[0].address

      if sale.seller is sale.creator
        @send(NotificationMessages.sellerByCashier(cashierName, sale.orderCode), sale.creator) unless sale.creator is userProfile.user
      else
        @send(NotificationMessages.saleCreatorByCashier(cashierName, sellerName, sale.orderCode), sale.creator) unless sale.creator is userProfile.user
        @send(NotificationMessages.saleSellerByCashier(cashierName, creatorName, sale.orderCode), sale.seller) unless sale.seller is userProfile.user

      #trực tiếp
      if sale.paymentsDelivery is 0
        for saleExporter in Schema.userProfiles.find({parentMerchant: userProfile.parentMerchant, roles: {$elemMatch: {$in:Role.rolesOf(Sky.system.merchantPermissions.saleExporter.key)}}}).fetch()
          @send(NotificationMessages.exportNotify(creatorName, sale.orderCode), saleExporter.user) unless userProfile.user is saleExporter.user
      #giao hàng
      if sale.paymentsDelivery is 1
        for shipper in Schema.userProfiles.find({parentMerchant: userProfile.parentMerchant, roles: {$elemMatch: {$in:Role.rolesOf(Sky.system.merchantPermissions.deliveryConfirm.key)}}}).fetch()
          @send(NotificationMessages.deliveryNotify(creatorName, sale.orderCode), shipper.user) unless userProfile.user is shipper.user

#TODO: Đang làm xác nhận lấy tiền lúc giao hàng
  @saleAccountingConfirmByDelivery: (sale) ->
    unless sale or sale.merchant is userProfile.currentMerchant then return
    userProfile = Schema.userProfiles.findOne({user: Meteor.userId()})
    unless Role.hasPermission(userProfile._id, Sky.system.merchantPermissions.cashierDelivery.key) then return
#    if sale.status == sale.success == sale.received == sale.exported == true and sale.submitted ==  sale.imported == false and sale.paymentsDelivery == 1

#kho
  @saleExporterConfirm: (sale) ->
    unless sale then return
    userProfile = Schema.userProfiles.findOne({user: Meteor.userId()})
    unless sale.merchant is userProfile.currentMerchant then return
    unless Role.hasPermission(userProfile._id, Sky.system.merchantPermissions.saleExport.key) then return
    if Sky.helpers.saleStatusIsExport(sale)
      exporterName = userProfile.fullName ? Meteor.user().emails[0].address
      creatorName = (Schema.userProfiles.findOne({user: sale.creator})).fullName ? Meteor.users.findOne(sale.creator).emails[0].address
      sellerName  = (Schema.userProfiles.findOne({user: sale.seller})).fullName ? Meteor.users.findOne(sale.seller).emails[0].address

      if sale.seller is sale.creator
        @send(NotificationMessages.sellerByExporter(exporterName, sale.orderCode), sale.creator) unless sale.creator is userProfile.user
      else
        @send(NotificationMessages.saleCreatorByExporter(exporterName, sellerName, sale.orderCode), sale.creator) unless sale.creator is userProfile.user
        @send(NotificationMessages.saleSellerByExporter(exporterName, creatorName, sale.orderCode), sale.seller) unless sale.seller is userProfile.user

      if sale.paymentsDelivery is 1
        shipperId = Schema.deliveries.findOne(sale.delivery).shipper
        @send(NotificationMessages.deliveryExport(exporterName, sale.orderCode), shipperId) unless shipperId is userProfile.user

  @saleImportConfirm: (sale) ->
    unless sale then return
    userProfile = Schema.userProfiles.findOne({user: Meteor.userId()})
    unless sale.merchant is userProfile.currentMerchant then return
    unless Role.hasPermission(userProfile._id, Sky.system.merchantPermissions.importDelivery.key) then return
    if Sky.helpers.saleStatusIsImport(sale)
      importerName = userProfile.fullName ? Meteor.user().emails[0].address
      creatorName = (Schema.userProfiles.findOne({user: sale.creator})).fullName ? Meteor.users.findOne(sale.creator).emails[0].address
      sellerName  = (Schema.userProfiles.findOne({user: sale.seller})).fullName ? Meteor.users.findOne(sale.seller).emails[0].address

      if sale.seller is sale.creator
        @send(NotificationMessages.sellerByImporter(importerName, sale.orderCode), sale.creator) unless sale.creator is userProfile.user
      else
        @send(NotificationMessages.saleCreatorByImporter(importerName, sellerName, sale.orderCode), sale.creator) unless sale.creator is userProfile.user
        @send(NotificationMessages.saleSellerByImporter(importerName, creatorName, sale.orderCode), sale.seller) unless sale.seller is userProfile.user

#giao hang
  @deliveryNotify: (sale, status) ->
    unless sale or (sale.paymentsDelivery is 1) then return
    userProfile = Schema.userProfiles.findOne({user: Meteor.userId()})
    unless sale.merchant is userProfile.currentMerchant then return
    unless Role.hasPermission(userProfile._id, Sky.system.merchantPermissions.deliveryConfirm.key) then return

    shipperName = userProfile.fullName ? Meteor.user().emails[0].address
    creatorName = (Schema.userProfiles.findOne({user: sale.creator})).fullName ? Meteor.users.findOne(sale.creator).emails[0].address
    sellerName  = (Schema.userProfiles.findOne({user: sale.seller})).fullName ? Meteor.users.findOne(sale.seller).emails[0].address

    if status is 'selected'
      if sale.seller is sale.creator
        @send(NotificationMessages.sellerByShipperSelected(shipperName, sale.orderCode), sale.creator) unless sale.creator is userProfile.user
      else
        @send(NotificationMessages.saleCreatorByShipperSelected(shipperName, sellerName, sale.orderCode), sale.creator) unless sale.creator is userProfile.user
        @send(NotificationMessages.saleSellerByShipperSelected(shipperName, creatorName, sale.orderCode), sale.seller) unless sale.seller is userProfile.user

      for saleExporter in Schema.userProfiles.find({parentMerchant: userProfile.parentMerchant, roles: {$elemMatch: {$in:Role.rolesOf(Sky.system.merchantPermissions.saleExporter.key)}}}).fetch()
        @send(NotificationMessages.exportNotify(creatorName, sale.orderCode), saleExporter.user) unless userProfile.user is receiver.user

    if status is 'working'
      if sale.seller is sale.creator
        @send(NotificationMessages.sellerByShipperWorking(shipperName, sale.orderCode), sale.creator) unless sale.creator is userProfile.user
      else
        @send(NotificationMessages.saleCreatorByShipperWorking(shipperName, sellerName, sale.orderCode), sale.creator) unless sale.creator is userProfile.user
        @send(NotificationMessages.saleSellerByShipperWorking(shipperName, creatorName, sale.orderCode), sale.seller) unless sale.seller is userProfile.user

    if status is 'success'
      if sale.seller is sale.creator
        @send(NotificationMessages.sellerByDeliverySuccess(shipperName, sale.orderCode), sale.creator) unless sale.creator is userProfile.user
      else
        @send(NotificationMessages.saleCreatorByDeliverySuccess(shipperName, sellerName, sale.orderCode), sale.creator) unless sale.creator is userProfile.user
        @send(NotificationMessages.saleSellerByDeliverySuccess(shipperName, creatorName, sale.orderCode), sale.seller) unless sale.seller is userProfile.user

    if status is 'fail'
      if sale.seller is sale.creator
        @send(NotificationMessages.sellerByDeliveryFail(shipperName, sale.orderCode), sale.creator) unless sale.creator is userProfile.user
      else
        @send(NotificationMessages.saleCreatorByDeliveryFail(shipperName, sellerName, sale.orderCode), sale.creator) unless sale.creator is userProfile.user
        @send(NotificationMessages.saleSellerByDeliveryFail(shipperName, creatorName, sale.orderCode), sale.seller) unless sale.seller is userProfile.user

#trả hàng


