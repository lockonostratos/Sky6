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
      Session.set "currentUser", Meteor.users.findOne(Meteor.userId())
      Session.set "availableMerchant", Schema.merchants.findOne({})

    if Session.get('currentUser') and Meteor.userId()
      Session.set "currentMerchant", Schema.merchants.findOne(Session.get('currentUser').profile.merchant)
      Session.set "currentWarehouse", Schema.warehouses.findOne(Session.get('currentUser').profile.warehouse)
      Session.set "availableStaffSale", Meteor.users.find({'profile.merchant': Session.get('currentUser').profile.merchant}).fetch()
      Session.set "availableCustomerSale", Schema.customers.find({currentMerchant: Session.get('currentUser').profile.parent}).fetch()

  Deps.autorun ->
    if Session.get('currentMerchant') and Meteor.userId()
      Session.set "availableWarehouses", Schema.warehouses.find({merchant: Session.get("currentMerchant")._id}).fetch()
      Session.set 'skullList', Schema.skulls.find({merchant: Session.get("currentMerchant")._id}).fetch()
      Session.set 'currentProviders', Schema.providers.find({merchant: Session.get("currentMerchant")._id, status: false}).fetch()
      Session.set 'availableProducts', Schema.products.find({merchant: Session.get('currentMerchant')._id}).fetch()

  Deps.autorun ->
    if Session.get('currentMerchant') and Meteor.userId()
      Session.set 'personalNewProducts', Schema.products.find({merchant: Session.get("currentMerchant")._id, creator: Meteor.userId(), totalQuality: 0},sort: {version:{createdAt: -1}}).fetch()
      Session.set 'personalNewProviders', Schema.providers.find({merchant: Session.get("currentMerchant")._id, creator: Meteor.userId()},sort: {version:{createdAt: -1}}).fetch()
      Session.set 'personalNewCustomers', Schema.customers.find({currentMerchant: Session.get("currentMerchant")._id, creator: Meteor.userId()}).fetch()
      Session.set 'personalNewWarehouses', Schema.warehouses.find({merchant: Session.get("currentMerchant")._id, creator: Meteor.userId()}).fetch()
      Session.set 'personalNewSkulls', Schema.skulls.find({merchant: Session.get("currentMerchant")._id, creator: Meteor.userId()}).fetch()

  Deps.autorun ->
    if Session.get('currentWarehouse') and Meteor.userId()
      Session.set 'availableDeliveries', Schema.deliveries.find({warehouse: Session.get('currentWarehouse')._id}).fetch()
      Session.set 'orderHistory', Schema.orders.find({warehouse: Session.get('currentWarehouse')._id}).fetch()
      if Session.get('orderHistory')
        Session.setDefault('currentOrder', Session.get('orderHistory')[0])
      if Session.get('currentOrder')
        Session.setDefault('currentOrderDetails', Schema.orderDetails.find({order: Session.get('currentOrder')._id}).fetch())

  Deps.autorun ->
    if Session.get('currentMerchant') and Meteor.userId()
      Sky.global.sellers = Meteor.users.find({}).fetch()
      Sky.global.personalNewProducts = Schema.products.find({merchant: Session.get("currentMerchant")._id, creator: Meteor.userId(), totalQuality: 0},sort: {version:{createdAt: -1}})

  Deps.autorun ->
    console.log "Your food is #{root.getFood()}"