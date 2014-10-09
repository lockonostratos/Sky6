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
    if Session.get('inventoryWarehouse')
      inventory = Schema.inventories.findOne(Session.get('inventoryWarehouse').inventory)
      if inventory?.creator == Meteor.userId()
        Session.set "currentInventory", inventory
      else
        Session.set "currentInventory"
    else
      Session.set "currentInventory"

    if Session.get('currentInventory')
      Session.set "availableProductDetails", Schema.inventoryDetails.find({inventory: Session.get('currentInventory')._id}).fetch()
    else
      Session.set "availableProductDetails"


Sky.appTemplate.extends Template.inventory,
  showName: -> 'wewe'
  inventory: -> Session.get('currentInventory')
  show: ->
    if Session.get('currentInventory') then true
    else
      if Session.get('inventoryWarehouse')?.checkingInventory == false
        true
      else
        false

  allowCreate: -> if Session.get('allowCreateNewInventory') then 'btn-success' else 'btn-default disabled'
  showDescription: ->
    if Session.get('inventoryWarehouse')?.checkingInventory == true and !Session.get("currentInventory") and Session.get("historyInventories")
      return "display: none"
  showCreate: -> return "display: none" if Session.get('currentInventory') || Session.get('inventoryWarehouse')?.checkingInventory == true
  showDestroy: -> return "display: none" if !Session.get('currentInventory') || Session.get('currentInventory')?.submit == true
  showSubmit: ->
    return "display: none" if !Session.get('availableProductDetails')
    for detail in Session.get('availableProductDetails')
      if detail.lock == false || detail.submit == false || detail.success == true
        return "display: none"

  merchantSelectOptions:
    query: (query) -> query.callback
      results: _.filter Session.get('allMerchantInventories'), (item) ->
        unsignedTerm = Sky.helpers.removeVnSigns query.term
        unsignedName = Sky.helpers.removeVnSigns item.name
        unsignedName.indexOf(unsignedTerm) > -1
    initSelection: (element, callback) -> callback(Session.get('inventoryMerchant') ? 'skyReset')
    formatSelection: formatMerchantSearch
    formatResult: formatMerchantSearch
    placeholder: 'CHỌN CHI NHÁNH'
    changeAction: (e) ->
      Schema.userProfiles.update Session.get('currentProfile')._id, $set:
        inventoryMerchant : e.added._id
        inventoryWarehouse: Schema.warehouses.findOne(merchant: e.added._id)?._id  ? 'skyReset'
    reactiveValueGetter: -> Session.get('inventoryMerchant') ? 0

  warehouseSelectOptions:
    query: (query) -> query.callback
      results: _.filter Session.get('allWarehouseInventory'), (item) ->
        unsignedTerm = Sky.helpers.removeVnSigns query.term
        unsignedName = Sky.helpers.removeVnSigns item.name
        unsignedName.indexOf(unsignedTerm) > -1
    initSelection: (element, callback) -> callback(Session.get('inventoryWarehouse') ? 'skyReset')
    formatSelection: formatWarehouseSearch
    formatResult: formatWarehouseSearch
    placeholder: 'CHỌN CHI NHÁNH'
    minimumResultsForSearch: -1
    changeAction: (e) ->
      Schema.userProfiles.update Session.get('currentProfile')._id, $set:
        inventoryWarehouse: e.added._id
      Session.set 'inventoryWarehouse', Schema.warehouses.findOne(e.added._id)
    reactiveValueGetter: -> Session.get('inventoryWarehouse') ? 'skyReset'

  productDetailOptions:
    itemTemplate: 'inventoryProductThumbnail'
    reactiveSourceGetter: -> Session.get('availableProductDetails') ? []
    wrapperClasses: 'detail-grid row'

  events:
    'click .creatInventory': (event, template)->
      if template.ui.$description.val().length > 1
        Inventory.createByWarehouse(Session.get('inventoryWarehouse')._id, template.ui.$description.val())
        Session.set('allowCreateNewInventory', false)

    'click .destroyInventory': (event, template)->
      if Session.get("currentInventory")?.creator == Meteor.userId()
        (Inventory.findOne(Session.get('inventoryWarehouse').inventory)).inventoryDestroy()
        Session.set('allowCreateNewInventory', false)

    'click .submitInventory': (event, template)->
      if Session.get("currentInventory")?.creator == Meteor.userId()
        (Inventory.findOne(Session.get('inventoryWarehouse').inventory)).inventorySuccess()
        Session.set('allowCreateNewInventory', false)

    "input input": (event, template) -> checkAllowCreate(template)

    'blur input': (event, template)->
      if Session.get("currentInventory")
        if template.ui.$description.val().length > 1
          Schema.inventories.update Session.get("currentInventory")._id, $set:{description: template.ui.$description.val()}
        else
          template.ui.$description.val(Session.get("currentInventory").description)

  rendered: ->
    runInitInventoryTracker()
