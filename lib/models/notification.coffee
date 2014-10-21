userHasPermission = (permission, userProfile)-> Role.hasPermission(userProfile._id, permission.key)
userNameBy = (userId)-> (Schema.userProfiles.findOne({user: userId})).fullName ? Meteor.users.findOne(userId).emails[0].address

sendAllUserOf = (permission, userProfile)->
  if permission and userHasPermission(Sky.system.merchantPermissions.permissionManagement, userProfile)
    allUserOfPermissionChanged = Schema.userProfiles.find(
      {
        parentMerchant: userProfile.parentMerchant
        roles: {$elemMatch: {$in:[permission.name]}}
      }).fetch()

    creatorName = userProfile.fullName ? Meteor.user().emails[0].address
    for receiver in allUserOfPermissionChanged
      unless userProfile.user is receiver.user
        Notification.send(NotificationMessages.permissionChanged(creatorName), receiver.user)

sendAllUserOnMerchantByNewMember = (newMemberName, companyName, userProfile)->
  if newMemberName and companyName and userHasPermission(Sky.system.merchantPermissions.permissionManagement, userProfile)
    for receiver in Schema.userProfiles.find({parentMerchant: userProfile.parentMerchant}).fetch()
      unless receiver.user is userProfile.user
        Notification.send(NotificationMessages.newMemberJoined(newMemberName, companyName), receiver.user)

sendSellerIfCreatorNotSeller = (sale, userProfile)->
  creatorName = userProfile.fullName ? Meteor.user().emails[0].address
  Notification.send(NotificationMessages.saleHelper(creatorName, sale.orderCode, sale.finalPrice), sale.seller)

sendAllUserHasPermissionCashierSale = (sale, userProfile) ->
  allUserHasPermissionCashierSale = Schema.userProfiles.find(
    {
      parentMerchant: userProfile.parentMerchant
      roles: {$elemMatch: {$in:Role.rolesOf(Sky.system.merchantPermissions.cashierSale.key)}}
    }).fetch()
  creatorName = userProfile.fullName ? Meteor.user().emails[0].address
  for receiver in allUserHasPermissionCashierSale
    unless userProfile.user is receiver.user
      Notification.send(NotificationMessages.sendAccountingByNewSale(creatorName, sale.orderCode), receiver.user)

sendToSellerAndCreatorBySaleConfirm = (cashierName, creatorName, sellerName, sale, userProfile)->
  if sale.seller is sale.creator
    unless sale.creator is userProfile.user
      Notification.send(NotificationMessages.sendByCashier(cashierName, sale.orderCode), sale.creator)
  else
    unless sale.creator is userProfile.user
      Notification.send(NotificationMessages.sendCreatorSaleByCashier(cashierName, sellerName, sale.orderCode), sale.creator)
    unless sale.seller is userProfile.user
      Notification.send(NotificationMessages.sendSellerSaleByCashier(cashierName, creatorName, sale.orderCode), sale.seller)

sendToExporterBySaleConfirm = (creatorName, sale, userProfile)->
  if sale.paymentsDelivery is 0
    allUserHasPermissionSaleExport = Schema.userProfiles.find(
      {
        parentMerchant: userProfile.parentMerchant
        roles: {$elemMatch: {$in:Role.rolesOf(Sky.system.merchantPermissions.saleExport.key)}}
      }).fetch()
    for exporter in allUserHasPermissionSaleExport
      unless userProfile.user is exporter.user
        Notification.send(NotificationMessages.sendExporterBySaleExport(creatorName, sale.orderCode), exporter.user)

sendToShipperBySaleConfirm = (creatorName, sale, userProfile)->
  if sale.paymentsDelivery is 1
    allUserHasPermissionDeliveryConfirm = Schema.userProfiles.find(
      {
        parentMerchant: userProfile.parentMerchant
        roles: {$elemMatch: {$in:Role.rolesOf(Sky.system.merchantPermissions.deliveryConfirm.key)}}
      }).fetch()
    for shipper in allUserHasPermissionDeliveryConfirm
      unless userProfile.user is shipper.user
        Notification.send(NotificationMessages.sendShipperByNewDelivery(creatorName, sale.orderCode), shipper.user)

sendToSellerAndCreatorByExporterConfirm = (exporterName, creatorName, sellerName, sale, userProfile)->
  if sale.seller is sale.creator
    unless sale.creator is userProfile.user
      Notification.send(NotificationMessages.sendByExporter(exporterName, sale.orderCode), sale.creator)
  else
    unless sale.creator is userProfile.user
      Notification.send(NotificationMessages.sendCreatorSaleByExporter(exporterName, sellerName, sale.orderCode), sale.creator)
    unless sale.seller is userProfile.user
      Notification.send(NotificationMessages.sendSellerSaleByExporter(exporterName, creatorName, sale.orderCode), sale.seller)

sendToShipperByExporterConfirm = (exporterName, sale, userProfile)->
  if sale.paymentsDelivery is 1
    shipperId = Schema.deliveries.findOne(sale.delivery).shipper
    unless shipperId is userProfile.user
      Notification.send(NotificationMessages.sendShipperByExport(exporterName, sale.orderCode), shipperId)

sendToSellerAndCreatorByImporterConfirm = (importerName, creatorName, sellerName, sale, userProfile)->
  if sale.seller is sale.creator
    unless sale.creator is userProfile.user
      Notification.send(NotificationMessages.sendByImporter(importerName, sale.orderCode), sale.creator)
  else
    unless sale.creator is userProfile.user
      Notification.send(NotificationMessages.sendCreatorSaleByImporter(importerName, sellerName, sale.orderCode), sale.creator)
    unless sale.seller is userProfile.user
      Notification.send(NotificationMessages.sendSellerSaleByImporter(importerName, creatorName, sale.orderCode), sale.seller)

sendToSellerAndCreatorByStatusIsSelected = (shipperName, creatorName, sellerName, sale, userProfile)->
  if sale.seller is sale.creator
    unless sale.creator is userProfile.user
      Notification.send(NotificationMessages.sendByShipperSelected(shipperName, sale.orderCode), sale.creator)
  else
    unless sale.creator is userProfile.user
      Notification.send(NotificationMessages.sendCreatorSaleByShipperSelected(shipperName, sellerName, sale.orderCode), sale.creator)
    unless sale.seller is userProfile.user
      Notification.send(NotificationMessages.sendSellerSaleByShipperSelected(shipperName, creatorName, sale.orderCode), sale.seller)

sendToSellerAndCreatorByStatusIsWorking = (shipperName, creatorName, sellerName, sale, userProfile)->
  if sale.seller is sale.creator
    unless sale.creator is userProfile.user
      Notification.send(NotificationMessages.sendByShipperWorking(shipperName, sale.orderCode), sale.creator)
  else
    unless sale.creator is userProfile.user
      Notification.send(NotificationMessages.sendCreatorSaleByShipperWorking(shipperName, sellerName, sale.orderCode), sale.creator)
    unless sale.seller is userProfile.user
      Notification.send(NotificationMessages.sendSellerSaleByShipperWorking(shipperName, creatorName, sale.orderCode), sale.seller)

sendToSellerAndCreatorByStatusIsSuccess = (shipperName, creatorName, sellerName, sale, userProfile)->
  if sale.seller is sale.creator
    unless sale.creator is userProfile.user
      Notification.send(NotificationMessages.sendByDeliverySuccess(shipperName, sale.orderCode), sale.creator)
  else
    unless sale.creator is userProfile.user
      Notification.send(NotificationMessages.sendCreatorSaleByDeliverySuccess(shipperName, sellerName, sale.orderCode), sale.creator)
    unless sale.seller is userProfile.user
      Notification.send(NotificationMessages.sendSellerSaleByDeliverySuccess(shipperName, creatorName, sale.orderCode), sale.seller)

sendToSellerAndCreatorByStatusIsFail = (shipperName, creatorName, sellerName, sale, userProfile)->
  if sale.seller is sale.creator
    unless sale.creator is userProfile.user
      Notification.send(NotificationMessages.sendByDeliveryFail(shipperName, sale.orderCode), sale.creator)
  else
    unless sale.creator is userProfile.user
      Notification.send(NotificationMessages.sendCreatorSaleByDeliveryFail(shipperName, sellerName, sale.orderCode), sale.creator)
    unless sale.seller is userProfile.user
      Notification.send(NotificationMessages.sendSellerSaleByDeliveryFail(shipperName, creatorName, sale.orderCode), sale.seller)

sendAllUserHasPermissionExportSale = (creatorName, sale, userProfile) ->
  allUserHasPermissionExportSale = Schema.userProfiles.find(
    {
      parentMerchant: userProfile.parentMerchant
      roles: {$elemMatch: {$in:Role.rolesOf(Sky.system.merchantPermissions.saleExport.key)}}
    }).fetch()
  for exporter in allUserHasPermissionExportSale
    unless userProfile.user is receiver.user
      Notification.send(NotificationMessages.sendExporterBySaleExport(creatorName, sale.orderCode), exporter.user)

sendAllUserHasPermissionReturnConfirm = (creatorName, returns, userProfile)->
  allUserHasPermissionReturnConfirm = Schema.userProfiles.find(
    {
      parentMerchant: userProfile.parentMerchant
      roles: {$elemMatch: {$in:Role.rolesOf(Sky.system.merchantPermissions.returnConfirm.key)}}
    }).fetch()
  for receiver in allUserHasPermissionReturnConfirm
    unless userProfile.user is receiver.user
      Notification.send(NotificationMessages.sendNewReturnCreate(creatorName, returns.returnCode), receiver.user)

sendAllUserHasPermissionInventoryConfirm = (creatorName, inventoryCode, userProfile)->
  allUserHasPermissionInventoryConfirm = Schema.userProfiles.find(
    {
      parentMerchant: userProfile.parentMerchant
      roles: {$elemMatch: {$in:Role.rolesOf(Sky.system.merchantPermissions.inventoryConfirm.key)}}
    }).fetch()
  for receiver in allUserHasPermissionInventoryConfirm
    unless userProfile.user is receiver.user
      @send(NotificationMessages.sendNewInventoryCreate(creatorName, inventoryCode), receiver.user)


Schema.add 'notifications', class Notification
  @send: (message, receiver, notificationType = Sky.notificationTypes.notify.key) ->
    newNotification = {
      sender: Meteor.userId()
      receiver: receiver
      message: message
      notificationType: notificationType
    }
    Schema.notifications.insert newNotification

  @permissionChanged: (permission) ->
    userProfile = Schema.userProfiles.findOne({user: Meteor.userId()})
    sendAllUserOf(permission, userProfile)

  @createNewMember: (newMemberName, companyName) ->
    userProfile = Schema.userProfiles.findOne({user: Meteor.userId()})
    sendAllUserOnMerchantByNewMember(newMemberName, companyName, userProfile)

  @newSaleDefault: (saleId) ->
    userProfile = Schema.userProfiles.findOne({user: Meteor.userId()})
    sale = Schema.sales.findOne({_id: saleId, creator: userProfile.user})
    if sale and userHasPermission(Sky.system.merchantPermissions.permissionManagement, userProfile)
      sendSellerIfCreatorNotSeller(sale, userProfile) if sale.creator isnt sale.seller
      sendAllUserHasPermissionCashierSale(sale, userProfile)


  @saleConfirmByAccounting: (saleId) ->
    userProfile = Schema.userProfiles.findOne({user: Meteor.userId()})
    sale = Schema.sales.findOne({_id: saleId, merchant: userProfile.currentMerchant})
    if sale and userHasPermission(Sky.system.merchantPermissions.cashierSale, userProfile)
      if sale.received == sale.imported ==  sale.exported == sale.submitted == false and sale.status == true
        cashierName = userProfile.fullName ? Meteor.user().emails[0].address
        creatorName = userNameBy(sale.creator)
        sellerName  = userNameBy(sale.seller)

        sendToSellerAndCreatorBySaleConfirm(cashierName, creatorName, sellerName, sale, userProfile)
        sendToExporterBySaleConfirm(creatorName, sale, userProfile)
        sendToShipperBySaleConfirm(creatorName, sale, userProfile)

  @saleAccountingConfirmByDelivery: (saleId) ->
    userProfile = Schema.userProfiles.findOne({user: Meteor.userId()})
    sale = Schema.sales.findOne({_id: saleId, merchant: userProfile.currentMerchant})
#    if sale and userHasPermission(Sky.system.merchantPermissions.cashierDelivery, userProfile)
#      if sale.status == sale.success == sale.received == sale.exported == true and sale.submitted ==  sale.imported == false and sale.paymentsDelivery == 1

#kho
  @saleConfirmByExporter: (saleId) ->
    userProfile = Schema.userProfiles.findOne({user: Meteor.userId()})
    sale = Schema.sales.findOne({_id: saleId, merchant: userProfile.currentMerchant})

    if sale and userHasPermission(Sky.system.merchantPermissions.saleExport, userProfile) and Sky.helpers.saleStatusIsExport(sale)
      exporterName = userProfile.fullName ? Meteor.user().emails[0].address
      creatorName = userNameBy(sale.creator)
      sellerName = userNameBy(sale.seller)

      sendToSellerAndCreatorByExporterConfirm(exporterName, creatorName, sellerName, sale, userProfile)
      sendToShipperByExporterConfirm(exporterName, sale, userProfile)

  @saleConfirmImporter: (saleId) ->
    userProfile = Schema.userProfiles.findOne({user: Meteor.userId()})
    sale = Schema.sales.findOne({_id: saleId, merchant: userProfile.currentMerchant})

    if sale and userHasPermission(Sky.system.merchantPermissions.importDelivery, userProfile) and Sky.helpers.saleStatusIsExport(sale)
      importerName = userProfile.fullName ? Meteor.user().emails[0].address
      creatorName = userNameBy(sale.creator)
      sellerName = userNameBy(sale.seller)

      sendToSellerAndCreatorByImporterConfirm(importerName, creatorName, sellerName, sale, userProfile)

  @deliveryNotify: (saleId, status) ->
    userProfile = Schema.userProfiles.findOne({user: Meteor.userId()})
    sale = Schema.sales.findOne({_id: saleId, merchant: userProfile.currentMerchant, paymentsDelivery: 1})

    if sale and userHasPermission(Sky.system.merchantPermissions.deliveryConfirm, userProfile)
      shipperName = userProfile.fullName ? Meteor.user().emails[0].address
      creatorName = userNameBy(sale.creator)
      sellerName = userNameBy(sale.seller)

      switch status
        when 'selected'
          sendToSellerAndCreatorByStatusIsSelected(shipperName, creatorName, sellerName, sale, userProfile)
          sendAllUserHasPermissionExportSale(creatorName, sale, userProfile)
        when 'working'
          sendToSellerAndCreatorByStatusIsWorking(shipperName, creatorName, sellerName, sale, userProfile)
        when 'success'
          sendToSellerAndCreatorByStatusIsSuccess(shipperName, creatorName, sellerName, sale, userProfile)
        when 'fail'
          sendToSellerAndCreatorByStatusIsFail(shipperName, creatorName, sellerName, sale, userProfile)

  @returnConfirm: (returnId)->
    userProfile = Schema.userProfiles.findOne({user: Meteor.userId()})
    returns = Schema.returns.findOne({_id: returnId, merchant: userProfile.currentMerchant, status: 0})

    if returns and userHasPermission(Sky.system.merchantPermissions.returnCreate, userProfile)
      creatorName = userProfile.fullName ? Meteor.user().emails[0].address
      sendAllUserHasPermissionReturnConfirm(creatorName, returns, userProfile)


  @returnSubmit: (retuenId)->
    userProfile = Schema.userProfiles.findOne({user: Meteor.userId()})
    returns = Schema.returns.findOne({_id: returnId, merchant: userProfile.currentMerchant, status: 1})

    if returns and userHasPermission(Sky.system.merchantPermissions.returnConfirm, userProfile)
      unless userProfile.user is returns.creator
        creatorName = userProfile.fullName ? Meteor.user().emails[0].address
        @send(NotificationMessages.sendCreatorByReturnConfirm(creatorName, returns.returnCode), returns.creator)

#kiem kho
  @inventoryNewCreate: (inventoryId)->
    userProfile = Schema.userProfiles.findOne({user: Meteor.userId()})
    inventory = Schema.inventories.findOne({_id: inventoryId, merchant: userProfile.currentMerchant, creator: {$ne: userProfile.user}})

    if inventory and userHasPermission(Sky.system.merchantPermissions.inventoryEdit, userProfile)
      creatorName = userProfile.fullName ? Meteor.user().emails[0].address
      inventoryCode = inventory.inventoryCode ? inventory.description
      sendAllUserHasPermissionInventoryConfirm(creatorName, inventoryCode, userProfile)

