formatWarehouseManagerSearch = (item) -> "#{item.name}" if item

checkAllowCreate = (context) ->
  name = context.ui.$name.val()

  if name.length > 0
    Session.set('allowCreateNewWarehouse', true)
  else
    Session.set('allowCreateNewWarehouse', false)

createWarehouse = (context) ->
  name = context.ui.$name.val()
  address = context.ui.$address.val()

  Schema.warehouses.insert
#    parentMerchant: Session.get('currentProfile').parentMerchant
    merchant          : Session.get('currentBranch')._id
    creator           : Meteor.userId()
    name              : name
    location          : {address: [address] if address}
    isRoot            : false
    checkingInventory : false

  resetForm(context)

resetForm = (context) -> $(item).val('') for item in context.findAll("[name]")

runInitWarehouseManagerTracker = ->
  return if Sky.global.warehouseManagerTracker
  Sky.global.warehouseManagerTracker = Tracker.autorun ->
    if Session.get("availableMerchant") and Session.get('currentProfile')?.currentMerchant
      Session.set "currentBranch", _.findWhere(Session.get("availableMerchant"), {_id: Session.get('currentProfile').currentMerchant})

Sky.appTemplate.extends Template.warehouseManager,
  allowCreate: -> if Session.get('allowCreateNewWarehouse') then 'btn-success' else 'btn-default disabled'
  created: ->  Session.setDefault('allowCreateNewWarehouse', false)

  merchantSelectOptions:
    query: (query) -> query.callback
      results: Session.get("availableMerchant")
    initSelection: (element, callback) -> callback(Session.get('currentBranch') ? 'skyReset')
    formatSelection: formatWarehouseManagerSearch
    formatResult: formatWarehouseManagerSearch
    placeholder: 'CHỌN SẢN CHI NHÁNH'
    minimumResultsForSearch: -1
    changeAction: (e) -> Session.set "currentBranch", _.findWhere(Session.get("availableMerchant"), {_id: e.added._id})
    reactiveValueGetter: -> Session.get('currentBranch') ? 'skyReset'

  warehouseDetailOptions:
    itemTemplate: 'warehouseThumbnail'
    reactiveSourceGetter: ->
      currentBranch = Session.get('currentBranch')
      if currentBranch then Schema.warehouses.find({merchant: currentBranch._id}).fetch() else []
    wrapperClasses: 'detail-grid row'

  events:
    "input input": (event, template) -> checkAllowCreate(template)
    "click #createBranch": (event, template) -> createWarehouse(template)

  rendered: ->
    runInitWarehouseManagerTracker()

