root = global ? window
autorunDebug = false;

Meteor.startup ->
  Tracker.autorun ->
    console.log ('userAutorunWorking..') if autorunDebug
    if Meteor.userId()
      Session.set "currentUser"       , Meteor.user()
      Session.set "currentProfile"    , Schema.userProfiles.findOne(user: Meteor.userId())
      Session.set "availableMerchant" , Schema.merchants.findOne({})

  Tracker.autorun ->
    console.log ('warehouseAutorunWorking..') if autorunDebug
    if Session.get('currentProfile')
      Session.set "currentMerchant"   , Schema.merchants.findOne(Session.get('currentProfile').currentMerchant)
      Session.set "currentWarehouse"  , Schema.warehouses.findOne(Session.get('currentProfile').currentWarehouse)

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
      Session.set 'availableDeliveries', Schema.deliveries.find({warehouse: Session.get('currentWarehouse')._id}).fetch()
      Session.set 'availableSale'   , Schema.sales.find({warehouse: Session.get("currentWarehouse")._id, status: true}).fetch()
      Session.set 'availableReturns'   , Schema.returns.find({warehouse: Session.get("currentWarehouse")._id}).fetch()

  messengerTracker = Tracker.autorun ->
    Session.set 'unreadMessages', Messenger.unreads().fetch()