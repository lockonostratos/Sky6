formatMerchantSearch = (item) -> "#{item.name}" if item
formatWarehouseSearch = (item) -> "#{item.name}" if item
formatViewInventorySearch = (item) -> "#{item.display}" if item

checkAllowCreate = (context) ->
  description = context.ui.$description.val()

  if description.length > 1
    Session.set('allowCreateNewInventory', true)
  else
    Session.set('allowCreateNewInventory', false)

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
      if inventory?.creator == Meteor.userId()
        Session.set "currentInventory", inventory
      else
        Session.set "currentInventory"
        Session.set "availableProductDetails"

    if Session.get('currentInventory')
      Session.set "availableProductDetails", Schema.inventoryDetails.find({inventory: Session.get('currentInventory')._id}).fetch()


Sky.appTemplate.extends Template.inventory,
  inventory: -> Session.get('currentInventory')
  allowCreate: -> if Session.get('allowCreateNewInventory') then 'btn-success' else 'btn-default disabled'

  showDescription: ->
    if Session.get('currentInventoryWarehouse')?.checkingInventory == true and !Session.get("currentInventory") and Session.get("historyInventories")
      return "display: none"
  showCreate: -> return "display: none" if Session.get('currentInventory') || Session.get('currentInventoryWarehouse')?.checkingInventory == true
  showDestroy: -> return "display: none" if !Session.get('currentInventory') || Session.get('currentInventory')?.submit == true
  showSubmit: ->
    return "display: none" if !Session.get('availableProductDetails')
    for detail in Session.get('availableProductDetails')
      if detail.lock == false || detail.submit == false || detail.success == true
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
    minimumResultsForSearch: -1
    changeAction: (e) ->
      Schema.userProfiles.update Session.get('currentProfile')._id, $set:
        currentInventoryWarehouse: e.added._id
    reactiveValueGetter: -> Session.get('currentInventoryWarehouse')

  productDetailOptions:
    itemTemplate: 'inventoryProductThumbnail'
    reactiveSourceGetter: -> Session.get('availableProductDetails') ? []
    wrapperClasses: 'detail-grid row'






  events:
    'click .creatInventory': (event, template)->
      if template.ui.$description.val().length > 1
        Inventory.createByWarehouse(Session.get('currentInventoryWarehouse')._id, template.ui.$description.val())

    'click .destroyInventory': (event, template)->
      if Session.get("currentInventory")?.creator == Meteor.userId()
        (Inventory.findOne(Session.get('currentInventoryWarehouse').inventory)).inventoryDestroy()
        Session.set('allowCreateNewInventory', false)

    'click .submitInventory': (event, template)->
      if Session.get("currentInventory")?.creator == Meteor.userId()
        (Inventory.findOne(Session.get('currentInventoryWarehouse').inventory)).inventorySuccess()

    "input input": (event, template) -> checkAllowCreate(template)

    'blur input': (event, template)->
      if Session.get("currentInventory")
        if template.ui.$description.val().length > 1
          Schema.inventories.update Session.get("currentInventory")._id, $set:{description: template.ui.$description.val()}
        else
          template.ui.$description.val(Session.get("currentInventory").description)

  rendered: ->
    runInitInventoryTracker()
