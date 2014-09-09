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
      Session.set "currentMerchant", Schema.merchants.findOne({}); root.currentMerchant = Session.get "currentMerchant"
      Session.set "availableStaffSale", Meteor.users.find({}).fetch()
      Session.set "availableCustomerSale", Schema.customers.find({}).fetch()

    if Session.get('currentMerchant')
      Session.set "currentWarehouse", Schema.warehouses.findOne({merchant: Session.get("currentMerchant")._id}); root.currentWarehouse = Session.get "currentWarehouse"

      Session.set 'skullList', Schema.skulls.find({merchant: Session.get("currentMerchant")._id}).fetch()
      Session.set 'currentProviders', Schema.providers.find({merchant: Session.get("currentMerchant")._id, status: false}).fetch()
      Session.set 'availableProducts', Schema.products.find(merchant: Session.get('currentMerchant')._id).fetch()

  Deps.autorun ->
    if Session.get('currentMerchant')
      Sky.global.sellers = Meteor.users.find({}).fetch()
      Sky.global.personalNewProducts = Schema.products.find({merchant: Session.get("currentMerchant")._id, creator: Meteor.userId(), totalQuality: 0},sort: {version:{createdAt: -1}})

      Session.set 'personalNewProducts', Schema.products.find({merchant: Session.get("currentMerchant")._id, creator: Meteor.userId(), totalQuality: 0},sort: {version:{createdAt: -1}}).fetch()
      Session.set 'personalNewProviders', Schema.providers.find({merchant: Session.get("currentMerchant")._id, creator: Meteor.userId()},sort: {version:{createdAt: -1}}).fetch()
      Session.set 'personalNewCustomers', Schema.customers.find({currentMerchant: Session.get("currentMerchant")._id, creator: Meteor.userId()}).fetch()
      Session.set 'personalNewWarehouses', Schema.warehouses.find({merchant: Session.get("currentMerchant")._id, creator: Meteor.userId()}).fetch()
      Session.set 'personalNewSkulls', Schema.skulls.find({merchant: Session.get("currentMerchant")._id, creator: Meteor.userId()}).fetch()
  #      Session.set 'personalNewStaffs', Schema.users.find({}).fetch()

  Deps.autorun ->
    Session.set('orderHistory', Schema.orders.find({}).fetch())
    if Session.get('orderHistory')
      Session.setDefault('currentOrder', Session.get('orderHistory')[0])
    if Session.get('currentOrder')
      Session.setDefault('currentOrderDetails', Schema.orderDetails.find({order: Session.get('currentOrder')._id}))

  Deps.autorun ->
    console.log "Your food is #{root.getFood()}"