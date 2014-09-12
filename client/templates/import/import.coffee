formatWarehouseSearch = (item) -> "#{item.name}" if item
formatImportSearch = (item) -> "#{item.description}" if item
_.extend Template.import,
  tabOptions:
    source: 'importHistory'
    currentSource: 'currentImport'
    caption: 'description'
    key: '_id'
    createAction: -> orderCreator()
    destroyAction: (instance) -> Schema.imports.remove(instance._id)

  warehouseSelectOptions:
    query: (query) -> query.callback
      results: Session.get('availableWarehouses')
      text: 'name'
    initSelection: (element, callback) -> callback Session.get('currentWarehouse')
    formatSelection: formatWarehouseSearch
    formatResult: formatWarehouseSearch
    id: '_id'
    placeholder: 'CHỌN KHO'
    minimumResultsForSearch: -1
    changeAction: (e) ->
      Meteor.users.update(Meteor.userId(), $set:{'profile.warehouse': e.added._id})
    reactiveValueGetter: -> Session.get('currentWarehouse')

  importSelectOptions:
    query: (query) -> query.callback
      results: Session.get('availableWarehouses')
      text: 'name'
    initSelection: (element, callback) -> callback Session.get('currentWarehouse')
    formatSelection: formatWarehouseSearch
    formatResult: formatWarehouseSearch
    id: '_id'
    placeholder: 'CHỌN KHO'
    minimumResultsForSearch: -1
    changeAction: (e) ->
      Meteor.users.update(Meteor.userId(), $set:{'profile.warehouse': e.added._id})
    reactiveValueGetter: -> Session.get('currentWarehouse')


  events:
    'click .addImport': (event, template)->
      currentWarehouse = Warehouse.findOne(Session.get('currentWarehouse')._id) if Session.get('currentWarehouse')
      currentWarehouse.addImport({description: template.find(".description").value})