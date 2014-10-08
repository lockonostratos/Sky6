root = global ? window
autorunDebug = false;

registerSounds = ->
  createjs.Sound.registerSound({src:"/sounds/incoming.mp3", id: "sound"})

Meteor.startup ->
  registerSounds()
#  Session.set('messengerVisibility', true)
#  Session.set('currentChatTarget', 'QsvgXdzKPzJxCMD9N')
  moment.locale('vi');
  Session.set('collapse', '');
  Sky.global.allMessages = Messenger.allMessages()
  Sky.global.currentMessages = Messenger.currentMessages()

  Tracker.autorun ->
    console.log ('userAutorunWorking..') if autorunDebug
    if Meteor.userId()
      Session.set "currentUser"       , Meteor.user()
      Session.set "currentProfile"    , Schema.userProfiles.findOne(user: Meteor.userId())

    if Session.get('currentProfile')?.parentMerchant
      availableMerchant = Schema.merchants.find(
        {$or:
          [
            {_id   : Session.get('currentProfile').parentMerchant}
            {parent: Session.get('currentProfile').parentMerchant}
          ]}
      ).fetch()

      Session.set "availableMerchant", availableMerchant
      Session.set 'availableCustomers', Schema.customers.find({parentMerchant: Session.get('currentProfile').parentMerchant}).fetch()

    if Session.get('currentProfile') #Temporaries SUBSCRUBIBE
      Meteor.subscribe 'merchantProfiles', Session.get('currentProfile').parentMerchant

  Tracker.autorun ->
    console.log ('merchant-warehouseAutorunWorking..') if autorunDebug
    if Session.get('currentProfile')
      if Session.get('currentProfile').parentMerchant == Session.get('currentProfile').currentMerchant
        Session.set "currentMerchant"   , Schema.merchants.findOne(Session.get('currentProfile').parentMerchant)
      else
        Session.set "currentMerchant"   , Schema.merchants.findOne({
          _id           : Session.get('currentProfile').currentMerchant
          parentMerchant: Session.get('currentProfile').parentMerchant   })

    if Session.get('currentMerchant')
      Session.set "availableWarehouses", Schema.warehouses.find({merchant: Session.get('currentMerchant')._id}).fetch()
      Session.set "currentWarehouse", Schema.warehouses.findOne({
        _id     : Session.get('currentProfile').currentWarehouse
        merchant: Session.get('currentMerchant')._id })

  Tracker.autorun ->
    console.log ('popoverAutorunWorking..') if autorunDebug
    if Session.get('currentProfile')?.parentMerchant

      if Session.get('currentWarehouse')
        Session.set 'availableProducts', Schema.products.find({warehouse: Session.get('currentWarehouse')._id}, Sky.helpers.defaultSort(1)).fetch()
        Session.set 'availableSaleProducts', Schema.products.find({
          warehouse: Session.get('currentWarehouse')._id
          price: {$gt: 0}
          instockQuality: {$gt: 0}
        }, Sky.helpers.defaultSort(1)).fetch()
        Session.set 'personalNewProducts', _.where(Session.get('availableProducts'), {creator: Session.get('currentProfile').user, totalQuality: 0}) if Session.get('availableProducts')

      availableProviders = Schema.providers.find({merchant: Session.get('currentProfile')?.parentMerchant }, Sky.helpers.defaultSort()).fetch()
      Session.set 'availableProviders', availableProviders
      if Session.get('availableProviders')
        providers = _.where(Session.get('availableProviders'), {merchant: Session.get('currentProfile')?.parentMerchant, creator: Session.get('currentProfile').user})
        if providers
          providerList= []
          for item in providers
            unless Schema.products.findOne({provider: item._id}) then providerList.push(item)
          Session.set 'personalNewProviders' , providerList



      #chưa fix(viet lai dep)
      if Session.get('currentMerchant')
        Session.set 'personalNewCustomers' , Schema.customers.find({currentMerchant: Session.get('currentMerchant')._id, creator: Meteor.userId()}).fetch()
        Session.set 'personalNewWarehouses', Schema.warehouses.find({merchant: Session.get('currentMerchant')._id, creator: Meteor.userId()}).fetch()
        Session.set 'personalNewSkulls'    , Schema.skulls.find({merchant: Session.get('currentMerchant')._id, creator: Meteor.userId()}).fetch()

        Session.set 'availableSkulls'      , Schema.skulls.find({merchant: Session.get('currentMerchant')._id}).fetch()
        Session.set 'currentProviders'     , Schema.providers.find({merchant: Session.get('currentMerchant')._id, status: false}).fetch()


  Tracker.autorun ->
    console.log ('inventoryAutorunWorking..') if autorunDebug
    if Session.get("availableMerchant") and Session.get('currentProfile')
      Session.set("allMerchantInventories", Session.get("availableMerchant"))
      inventoryMerchant = _.findWhere(Session.get("allMerchantInventories"), {_id: Session.get('currentProfile').inventoryMerchant})

      if inventoryMerchant
        Session.set "inventoryMerchant", inventoryMerchant
        allWarehouseInventory = Schema.warehouses.find({merchant: inventoryMerchant._id}).fetch()
        Session.set "allWarehouseInventory", allWarehouseInventory
      else
        Session.set "inventoryMerchant"
        Session.set "allWarehouseInventory"

  Tracker.autorun ->
    console.log ('exportAutorunWorking..') if autorunDebug
    if Session.get("availableMerchant") and Session.get('currentProfile')
      exportMerchant = _.findWhere(Session.get("availableMerchant"), {_id: Session.get('currentProfile').exportMerchant})
      targetExportMerchant = _.findWhere(Session.get("availableMerchant"), {_id: Session.get('currentProfile').targetExportMerchant})

      if exportMerchant
        Session.set "exportMerchant", exportMerchant

        availableExportWarehouses = Schema.warehouses.find({merchant: exportMerchant._id}).fetch()
        Session.set "availableExportWarehouses", availableExportWarehouses

        exportWarehouse = _.findWhere(availableExportWarehouses, {_id: Session.get('currentProfile').exportWarehouse})
        if exportWarehouse then Session.set "exportWarehouse", exportWarehouse
        else
          if availableExportWarehouses.length < 1
            Session.set "exportWarehouse"
          else
            Session.set "exportWarehouse", availableExportWarehouses[0]
      else
        Session.set "exportMerchant"
        Session.set "exportWarehouse"
        Session.set "availableExportWarehouses"

      if targetExportMerchant
        Session.set "targetExportMerchant", targetExportMerchant

        availableTargetExportWarehouses = Schema.warehouses.find({merchant: targetExportMerchant._id}).fetch()
        Session.set "availableTargetExportWarehouses", availableTargetExportWarehouses

        targetExportWarehouse = Schema.warehouses.findOne(Session.get('currentProfile').targetExportWarehouse)
        if targetExportWarehouse
          Session.set "targetExportWarehouse", targetExportWarehouse
        else
          if availableTargetExportWarehouses.length < 1
            Session.set "targetExportWarehouse"
          else
            Session.set "targetExportWarehouse", availableTargetExportWarehouses[0]
      else
        Session.set "targetExportMerchant"
        Session.set "targetExportWarehouse"
        Session.set "availableTargetExportWarehouses"

  Tracker.autorun ->
    console.log ('deliveriesAutorunWorking..') if autorunDebug
    if Session.get('currentWarehouse')
      Session.set 'availableSale'   , Schema.sales.find({warehouse: Session.get("currentWarehouse")._id, status: true}).fetch()
      Session.set 'availableReturns'   , Schema.returns.find({warehouse: Session.get("currentWarehouse")._id}).fetch()

  messengerTracker = Tracker.autorun ->
    Session.set 'unreadMessages', Messenger.unreads().fetch()
    Session.set 'incommingMessages', Messenger.incommings().fetch()