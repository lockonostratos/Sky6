root = global ? window
root.food = "apple"
root.foodDep = new Deps.Dependency
root.getFood = -> root.foodDep.depend(); root.food
root.setFood = (val) ->
  foodDep.changed() if val isnt root.food
  root.food = val
root.test = new Tracker.Dependency
Sky.global.salesDep = new Deps.Dependency

Meteor.startup ->
  Deps.autorun ->
    if Meteor.userId()
      Session.set "currentUser"       , Meteor.users.findOne(Meteor.userId())
      Session.set "availableMerchant" , Schema.merchants.findOne({})

  Deps.autorun ->
    if Session.get('currentUser')
      Session.set "currentMerchant"   , Schema.merchants.findOne(Session.get('currentUser').profile.merchant)
      Session.set "currentWarehouse"  , Schema.warehouses.findOne(Session.get('currentUser').profile.warehouse)

  Deps.autorun ->
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

  Deps.autorun ->
    if Session.get('currentWarehouse')
      Session.set 'availableDeliveries', Schema.deliveries.find({warehouse: Session.get('currentWarehouse')._id}).fetch()

  Deps.autorun ->
    if Session.get('currentMerchant')
      Sky.global.sellers = Meteor.users.find({}).fetch()
      Sky.global.personalNewProducts = Schema.products.find({merchant: Session.get("currentMerchant")._id, creator: Meteor.userId(), totalQuality: 0},sort: {version:{createdAt: -1}})

  Deps.autorun ->
    console.log "Your food is #{root.getFood()}"