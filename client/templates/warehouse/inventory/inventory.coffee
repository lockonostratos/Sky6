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
      if Session.get('currentProfile')?.currentInventoryView == 0
        inventory = Schema.inventories.findOne(Session.get('currentInventoryWarehouse').inventory)
        if inventory?.creator == Meteor.userId()
          Session.set "currentInventory", inventory
          if Session.get('currentInventory')
            Session.set "availableProductDetails", Schema.inventoryDetails.find({inventory: Session.get('currentInventory')._id}).fetch()

          Session.set "historyInventories"
        else
          Session.set "currentInventory"
          Session.set "availableProductDetails"

        Session.set "historyInventories"

      if Session.get('currentProfile')?.currentInventoryView == 1
        historyInventory = Schema.inventories.find({warehouse: Session.get('currentInventoryWarehouse')._id}).fetch()
        if historyInventory
          Session.set "historyInventories", historyInventory

        Session.set "currentInventory"
        Session.set "availableProductDetails"

      if Session.get('currentProfile')?.currentInventoryView == 2
        listUnSuccessInventories = Schema.inventories.find({warehouse: Session.get('currentInventoryWarehouse')._id, success: false, submit: true}).fetch()
        if listUnSuccessInventories.length > 0
          Session.set "historyInventories", historyInventory
          if Session.get('currentProfile')?.currentUnSuccessInventory
            Session.set "historyInventories"
          else
#            Session.set "historyInventories"

        else
          Session.set "historyInventories"

        Session.set "currentInventory"
        Session.set "availableProductDetails"
        Session.set "historyInventories"









Sky.appTemplate.extends Template.inventory,
  inventory: -> Session.get('currentInventory')
  historyInventories: -> Session.get('historyInventories')
  showInventoryDetail: -> if Session.get('currentInventory') then true else false
  showHistoryInventories: -> if Session.get('historyInventories') then true else false
  allowCreate: -> if Session.get('allowCreateNewInventory') then 'btn-success' else 'btn-default disabled'

  showDescription: ->
    inventoryView = Session.get('currentProfile')?.currentInventoryView
    if inventoryView == 1 || inventoryView == 2 then return "display: none"
    if Session.get('currentInventoryWarehouse')?.checkingInventory == true and !Session.get("currentInventory") and Session.get("historyInventories")
      return "display: none"

  showCreate: ->
    inventoryView = Session.get('currentProfile')?.currentInventoryView
    if inventoryView == 1 || inventoryView == 2 then return "display: none"
    return "display: none" if Session.get('currentInventory') || Session.get('currentInventoryWarehouse')?.checkingInventory == true

  showDestroy: ->
    inventoryView = Session.get('currentProfile')?.currentInventoryView
    if inventoryView == 1 || inventoryView == 2 then return "display: none"
    return "display: none" if !Session.get('currentInventory') || Session.get('currentInventory')?.submit == true

  showSubmit: ->
    inventoryView = Session.get('currentProfile')?.currentInventoryView
    if inventoryView == 1 || inventoryView == 2 then return "display: none"
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

  viewInventorySelectOption:
    query: (query) -> query.callback
      results: Sky.system.viewInventories
      text: 'id'
    initSelection: (element, callback) -> callback _.findWhere(Sky.system.viewInventories, {_id: Session.get('currentProfile')?.currentInventoryView ? 0})
    formatSelection: formatViewInventorySearch
    formatResult: formatViewInventorySearch
    placeholder: 'CHỌN XEM'
    minimumResultsForSearch: -1
    changeAction: (e) ->
      Schema.userProfiles.update Session.get('currentProfile')._id, $set: {currentInventoryView: e.added._id}
    reactiveValueGetter: -> _.findWhere(Sky.system.viewInventories, {_id: Session.get('currentProfile')?.currentInventoryView ? 0})

  productDetailOptions:
    itemTemplate: 'inventoryProductThumbnail'
    reactiveSourceGetter: -> Session.get('availableProductDetails') ? []
    wrapperClasses: 'detail-grid row'

  inventoryOptions:
    itemTemplate: 'inventoryThumbnail'
    reactiveSourceGetter: -> Session.get('historyInventories') ? []
    wrapperClasses: 'detail-grid row'





  events:
    'click .creatInventory': (event, template)->
      if template.ui.$description.val().length > 1
        Inventory.createByWarehouse(Session.get('currentInventoryWarehouse')._id, template.ui.$description.val())

    'click .destroyInventory': (event, template)->
      if Session.get("currentInventory")?.creator == Meteor.userId()
        (Inventory.findOne(Session.get('currentInventoryWarehouse').inventory)).inventoryDestroy()

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
