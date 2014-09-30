root = global ? window
autorunDebug = false;

registerSounds = ->
  createjs.Sound.registerSound({src:"/sounds/incoming.mp3", id: "sound"})

Meteor.startup ->
  registerSounds()
#  Session.set('messengerVisibility', true)
#  Session.set('currentChatTarget', 'QsvgXdzKPzJxCMD9N')
  Session.set('collapse', '');
  Sky.global.allMessages = Messenger.allMessages()
  Sky.global.currentMessages = Messenger.currentMessages()

  Tracker.autorun ->
    console.log ('userAutorunWorking..') if autorunDebug
    if Meteor.userId()
      Session.set "currentUser"       , Meteor.user()
      Session.set "currentProfile"    , Schema.userProfiles.findOne(user: Meteor.userId())
      Session.set "availableMerchant" , Schema.merchants.find({}).fetch()

    if Session.get('currentProfile') #Temporaries SUBSCRUBIBE
      Meteor.subscribe 'merchantProfiles', Session.get('currentProfile').parentMerchant

  Tracker.autorun ->
    console.log ('warehouseAutorunWorking..') if autorunDebug
    if Session.get('currentProfile')
      Session.set "currentMerchant"   , Schema.merchants.findOne(Session.get('currentProfile').currentMerchant)
      Session.set "currentWarehouse"  , Schema.warehouses.findOne(Session.get('currentProfile').currentWarehouse)

  Tracker.autorun ->
    console.log ('inventoryAutorunWorking..') if autorunDebug
    if Session.get('currentProfile')
      allMerchant = Schema.merchants.find({}).fetch()
      Session.set "availableMerchantInventories", allMerchant

      inventoryMerchant = Schema.merchants.findOne(Session.get('currentProfile').inventoryMerchant)
      inventoryWarehouse = Schema.warehouses.findOne(Session.get('currentProfile').inventoryWarehouse)

      if inventoryMerchant
        Session.set "inventoryMerchant", inventoryMerchant
        Session.set "availableWarehouseInventories", Schema.warehouses.find({merchant: inventoryMerchant._id}).fetch()
      else
        Session.set "inventoryMerchant"
        Session.set "availableWarehouseInventories"

      if inventoryWarehouse?.merchant == inventoryMerchant?._id
        Session.set "inventoryWarehouse", inventoryWarehouse
      else
        Session.set "inventoryWarehouse"

  Tracker.autorun ->
    console.log ('productAutorunWorking..') if autorunDebug
    if Session.get('currentMerchant')
      Session.set "availableWarehouses"  , Schema.warehouses.find({merchant: Session.get("currentMerchant")._id}).fetch()
      Session.set 'availableProducts'    , Schema.products.find({merchant: Session.get('currentMerchant')._id}).fetch()

      Session.set 'personalNewProducts'  , Schema.products.find({merchant: Session.get("currentMerchant")._id, creator: Meteor.userId(), totalQuality: 0},sort: {version:{createdAt: -1}}).fetch()
      Session.set 'personalNewProviders' , Schema.providers.find({merchant: Session.get("currentMerchant")._id, creator: Meteor.userId()},sort: {version:{createdAt: -1}}).fetch()
      Session.set 'personalNewCustomers' , Schema.customers.find({currentMerchant: Session.get("currentMerchant")._id, creator: Meteor.userId()}).fetch()
      Session.set 'personalNewWarehouses', Schema.warehouses.find({merchant: Session.get("currentMerchant")._id, creator: Meteor.userId()}).fetch()
      Session.set 'personalNewSkulls'    , Schema.skulls.find({merchant: Session.get("currentMerchant")._id, creator: Meteor.userId()}).fetch()

      Session.set 'availableProviders'   , Schema.providers.find({merchant: Session.get('currentMerchant')._id}).fetch()
      Session.set 'availableSkulls'      , Schema.skulls.find({merchant: Session.get("currentMerchant")._id}).fetch()
      Session.set 'currentProviders'     , Schema.providers.find({merchant: Session.get("currentMerchant")._id, status: false}).fetch()

  Tracker.autorun ->
    console.log ('deliveriesAutorunWorking..') if autorunDebug
    if Session.get('currentWarehouse')
      Session.set 'availableSale'   , Schema.sales.find({warehouse: Session.get("currentWarehouse")._id, status: true}).fetch()
      Session.set 'availableReturns'   , Schema.returns.find({warehouse: Session.get("currentWarehouse")._id}).fetch()

  messengerTracker = Tracker.autorun ->
    Session.set 'unreadMessages', Messenger.unreads().fetch()
    Session.set 'incommingMessages', Messenger.incommings().fetch()