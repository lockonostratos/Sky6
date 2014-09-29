formatMerchantSearch = (item) -> "#{item.name}" if item
formatWarehouseSearch = (item) -> "#{item.name}" if item

runInitInventoryTracker = (context) ->
  return if Sky.global.inventoryTracker
  Sky.global.inventoryTracker = Tracker.autorun ->
    if Session.get('currentProfile')
      Session.set "availableInventoryMerchants", Schema.merchants.find({}).fetch()

    if Session.get('availableInventoryMerchants') and Session.get('currentProfile')
      Session.set "currentInventoryMerchant", Schema.merchants.findOne(Session.get('currentProfile').currentInventoryMerchant)

    if Session.get('currentInventoryMerchant')
      Session.set "availableInventoryWarehouses", Schema.warehouses.find({merchant: Session.get('currentInventoryMerchant')._id}).fetch()

    if Session.get('availableInventoryWarehouses') and Session.get('currentProfile')
      Session.set "currentInventoryWarehouse", Schema.warehouses.findOne(Session.get('currentProfile').currentInventoryWarehouse) ? 'skyReset'

    if Session.get('currentInventoryWarehouse')
      inventory = Schema.inventories.findOne(Session.get('currentInventoryWarehouse').inventory)
      if inventory
        Session.set "currentInventory", inventory
      else
        Session.set "currentInventory"

    if Session.get('currentInventory')
      Session.set "availableProductDetails", Schema.inventoryDetails.find({inventory: Session.get('currentInventory')._id}).fetch()
    else
      Session.set "availableProductDetails"




Sky.appTemplate.extends Template.inventory,
  inventory: -> Session.get('currentInventory')
  showCreate: -> return "display: none" if Session.get('currentInventory')
  showDestroy: -> return "display: none" if !Session.get('currentInventory')
  showSubmit: ->
    return "display: none" if !Session.get('availableProductDetails')
    for detail in Session.get('availableProductDetails')
      if detail.lock == false || detail.submit == false
        return "display: none"

  merchantSelectOptions:
    query: (query) -> query.callback
      results: _.filter Session.get('availableInventoryMerchants'), (item) ->
        unsignedTerm = Sky.helpers.removeVnSigns query.term
        unsignedName = Sky.helpers.removeVnSigns item.name
        unsignedName.indexOf(unsignedTerm) > -1
    initSelection: (element, callback) -> callback(Session.get('currentInventoryMerchant') ? 0)
    formatSelection: formatMerchantSearch
    formatResult: formatMerchantSearch
    placeholder: 'CHỌN CHI NHÁNH'
    changeAction: (e) ->
      Schema.userProfiles.update Session.get('currentProfile')._id, $set:
        currentInventoryMerchant : e.added._id
        currentInventoryWarehouse: Schema.warehouses.findOne(merchant: e.added._id)?._id  ? 'skyReset'
    reactiveValueGetter: -> Session.get('currentInventoryMerchant') ? 0

  warehouseSelectOptions:
    query: (query) -> query.callback
      results: _.filter Session.get('availableInventoryWarehouses'), (item) ->
        unsignedTerm = Sky.helpers.removeVnSigns query.term
        unsignedName = Sky.helpers.removeVnSigns item.name
        unsignedName.indexOf(unsignedTerm) > -1
    initSelection: (element, callback) -> callback(Session.get('currentInventoryWarehouse'))
    formatSelection: formatWarehouseSearch
    formatResult: formatWarehouseSearch
    placeholder: 'CHỌN CHI NHÁNH'
    changeAction: (e) ->
      Schema.userProfiles.update Session.get('currentProfile')._id, $set:
        currentInventoryWarehouse: e.added._id
    reactiveValueGetter: -> Session.get('currentInventoryWarehouse')

  productDetailOptions:
    itemTemplate: 'inventoryProductThumbnail'
    reactiveSourceGetter: -> Session.get('availableProductDetails') ? []
    wrapperClasses: 'detail-grid row'

  events:
    'click .creatInventory': (event, template)-> Inventory.createByWarehouse(Session.get('currentInventoryWarehouse')._id, "Khiem KHo Dau Nam")
    'click .destroyInventory': (event, template)-> Inventory.destroy(Session.get('currentInventoryWarehouse').inventory)
    'click .submitInventory': (event, template)-> Inventory.createByWarehouse(Session.get('currentInventoryWarehouse')._id)

    'blur input': (event, template)->
      if template.ui.$description.val().length > 1
        Schema.inventories.update Session.get("currentInventory")._id, $set:{description: template.ui.$description.val()}
      else
        template.ui.$description.val(Session.get("currentInventory").description)

  rendered: ->
    runInitInventoryTracker()
