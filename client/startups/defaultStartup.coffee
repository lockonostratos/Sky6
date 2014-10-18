root = global ? window
autorunDebug = false;

registerSounds = ->
  createjs.Sound.registerSound({src:"/sounds/incoming.mp3", id: "sound"})

Meteor.startup ->
  registerSounds()
  moment.locale('vi');
  Session.set('collapse', '');

  Tracker.autorun ->
    console.log ('userAutorunWorking..') if autorunDebug
    if Meteor.userId()
      Session.set "currentUser"    , Meteor.user()
      Session.set "currentProfile" , Schema.userProfiles.findOne(user: Meteor.userId())
    else
      Session.set "currentUser"
      Session.set "currentProfile"

  Tracker.autorun ->
    console.log ('merchantPackagesAutorunWorking..') if autorunDebug
    if Session.get('currentProfile')
      if Session.get('currentProfile').isRoot
        merchantPackages = Schema.merchantPackages.findOne({user: Meteor.userId()})
      else
        merchantPackages = Schema.merchantPackages.findOne({merchant: Session.get('currentProfile').parentMerchant})
      Session.set "merchantPackages", merchantPackages
    else
      Session.set "merchantPackages"

  Tracker.autorun ->
    if Session.get('merchantPackages')?.merchantRegistered
      parentMerchantId  = Session.get('currentProfile').parentMerchant
      currentMerchantId= Session.get('currentProfile').currentMerchant

      availableMerchant = Schema.merchants.find({
        $or:[
          {_id   : parentMerchantId}
          {parent: parentMerchantId}] }).fetch()

      if currentMerchantId is parentMerchantId
        currentMerchant = Schema.merchants.findOne(parentMerchantId)
      else
        currentMerchant = Schema.merchants.findOne({
          _id           : currentMerchantId
          parentMerchant: parentMerchantId })

      metroSummary         = Schema.metroSummaries.findOne({merchant: parentMerchantId})
      availableCustomers   = Schema.customers.find({parentMerchant: parentMerchantId}).fetch()
      availableUserProfile = Schema.userProfiles.find({parentMerchant: parentMerchantId}).fetch()

      #Temporaries SUBSCRUBIBE
      Meteor.subscribe 'merchantProfiles' , parentMerchantId

      Session.set "metroSummary"          , metroSummary
      Session.set "availableMerchant"     , availableMerchant
      Session.set 'availableCustomers'    , availableCustomers
      Session.set "availableUserProfile"  , availableUserProfile
      Session.set "currentMerchant"       , currentMerchant
    else
      Session.set "metroSummary"
      Session.set "availableMerchant"
      Session.set "availableCustomers"
      Session.set "availableUserProfile"
      Session.set "currentMerchant"

  Tracker.autorun ->
    if Session.get('currentMerchant')
      currentMerchantId = Session.get('currentMerchant')._id

      availableSkulls = Schema.skulls.find({merchant: currentMerchantId}).fetch()
      availableWarehouses = Schema.warehouses.find({merchant: currentMerchantId}).fetch()

      currentProviders = Schema.providers.find({merchant: currentMerchantId, status: false}).fetch()
      currentWarehouse = Schema.warehouses.findOne({
        _id     : Session.get('currentProfile').currentWarehouse
        merchant: currentMerchantId })

      personalNewCustomers = Schema.customers.find({currentMerchant: currentMerchantId, creator: Meteor.userId()}).fetch()
      personalNewWarehouses = Schema.warehouses.find({merchant: currentMerchantId, creator: Meteor.userId()}).fetch()
      personalNewSkulls = Schema.skulls.find({merchant: currentMerchantId, creator: Meteor.userId()}).fetch()

      Session.set 'availableSkulls'      , availableSkulls
      Session.set "availableWarehouses"  , availableWarehouses
      Session.set "currentWarehouse"     , currentWarehouse
      Session.set 'currentProviders'     , currentProviders
      Session.set 'personalNewCustomers' , personalNewCustomers
      Session.set 'personalNewWarehouses', personalNewWarehouses
      Session.set 'personalNewSkulls'    , personalNewSkulls
    else
      Session.set "availableWarehouses"
      Session.set "availableSkulls"
      Session.set "currentWarehouse"
      Session.set "currentProviders"
      Session.set "personalNewCustomers"
      Session.set "personalNewWarehouses"
      Session.set "personalNewSkulls"

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

      if Session.get("allWarehouseInventory")?.length > 0
        inventoryWarehouse = _.findWhere(Session.get("allWarehouseInventory"), {_id: Session.get('currentProfile').inventoryWarehouse})
        if inventoryWarehouse
          Session.set "inventoryWarehouse", Schema.warehouses.findOne(inventoryWarehouse._id)
        else
          Session.set "inventoryWarehouse", Session.get("allWarehouseInventory")[0]
      else
        Session.set "inventoryWarehouse"

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
      Session.set 'availableReturns', Schema.returns.find({warehouse: Session.get("currentWarehouse")._id}).fetch()
    else
      Session.set 'availableSale'
      Session.set 'availableReturns'


