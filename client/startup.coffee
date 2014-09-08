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
    Session.set "mostExpensiveProduct", Schema.products.findOne({}, {sort: {price: -1}})
    root.mostExpensiveProduct = Session.get "mostExpensiveProduct"

    Session.set "currentMerchant", Schema.merchants.findOne({})
    root.currentMerchant = Session.get "currentMerchant"

    if root.currentMerchant
      Session.set "currentWarehouse", Schema.warehouses.findOne({merchant: root.currentMerchant._id}); root.currentWarehouse = Session.get "currentWarehouse"
      Session.set 'skullList', Schema.skulls.find({merchant: root.currentMerchant._id}).fetch()
      Session.set 'currentProviders', Schema.providers.find({merchant: root.currentMerchant._id, status: false}).fetch()



#    Session.set "personalNewProducts",
    Sky.global.personalNewProducts = Schema.products.find({creator: Meteor.userId(), totalQuality: 0},sort: {version:{createdAt: -1}})

    if Session.get('currentMerchant')
      Session.set('availableProducts', Schema.products.find(merchant: Session.get('currentMerchant')._id).fetch())

    #   Session.set "personalNewProducts",
    Sky.global.personalNewProducts = Schema.products.find({creator: Meteor.userId(), totalQuality: 0},sort: {version:{createdAt: -1}})

    Sky.global.sellers = Meteor.users.find({}).fetch()

  Deps.autorun ->
    Session.set('orderHistory', Schema.orders.find({}).fetch())
    if Session.get('orderHistory')
      Session.setDefault('currentOrder', Session.get('orderHistory')[0])
    if Session.get('currentOrder')
      Session.setDefault('currentOrderDetails', Schema.orderDetails.find({order: Session.get('currentOrder')._id}))

  Deps.autorun ->
    console.log "Your food is #{root.getFood()}"