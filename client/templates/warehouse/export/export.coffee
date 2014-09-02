formatMerchantSearch = (item) -> "#{item.name}" if item
formatWarehouseSearch = (item) -> "#{item.name}" if item
formatfilterDeliverySearch = (item) -> "#{item.display}" if item

runInitExportTracker = (context) ->
  return if Sky.global.exportTracker
  Sky.global.exportTracker = Tracker.autorun ->




Sky.appTemplate.extends Template.export,

  merchantSelectOptions:
    query: (query) -> query.callback
      results: _.filter Session.get('availableDeliveryMerchants'), (item) ->
        unsignedTerm = Sky.helpers.removeVnSigns query.term
        unsignedName = Sky.helpers.removeVnSigns item.name
        unsignedName.indexOf(unsignedTerm) > -1
    initSelection: (element, callback) -> callback(Session.get('currentDeliveryMerchant') ? 0)
    formatSelection: formatMerchantSearch
    formatResult: formatMerchantSearch
    placeholder: 'CHỌN CHI NHÁNH'
    changeAction: (e) ->
      Schema.userProfiles.update Session.get('currentProfile')._id, $set:
        currentDeliveryMerchant : e.added._id
        currentDeliveryWarehouse: Schema.warehouses.findOne(merchant: e.added._id)?._id  ? 'skyReset'
        currentDeliveryFilter   : 0
    reactiveValueGetter: -> Session.get('currentDeliveryMerchant') ? 0
  merchantSelectOptions:
    query: (query) -> query.callback
      results: _.filter Session.get('availableDeliveryMerchants'), (item) ->
        unsignedTerm = Sky.helpers.removeVnSigns query.term
        unsignedName = Sky.helpers.removeVnSigns item.name
        unsignedName.indexOf(unsignedTerm) > -1
    initSelection: (element, callback) -> callback(Session.get('currentDeliveryMerchant') ? 0)
    formatSelection: formatMerchantSearch
    formatResult: formatMerchantSearch
    placeholder: 'CHỌN CHI NHÁNH'
    changeAction: (e) ->
      Schema.userProfiles.update Session.get('currentProfile')._id, $set:
        currentDeliveryMerchant : e.added._id
        currentDeliveryWarehouse: Schema.warehouses.findOne(merchant: e.added._id)?._id  ? 'skyReset'
        currentDeliveryFilter   : 0
    reactiveValueGetter: -> Session.get('currentDeliveryMerchant') ? 0

  warehouseSelectOptions:
    query: (query) -> query.callback
      results: _.filter Session.get('availableDeliveryWarehouses'), (item) ->
        unsignedTerm = Sky.helpers.removeVnSigns query.term
        unsignedName = Sky.helpers.removeVnSigns item.name
        unsignedName.indexOf(unsignedTerm) > -1
    initSelection: (element, callback) -> callback(Session.get('currentDeliveryWarehouse'))
    formatSelection: formatWarehouseSearch
    formatResult: formatWarehouseSearch
    placeholder: 'CHỌN CHI NHÁNH'
    changeAction: (e) ->
      Schema.userProfiles.update Session.get('currentProfile')._id, $set:
        currentDeliveryWarehouse: e.added._id
        currentDeliveryFilter   : 0
    reactiveValueGetter: -> Session.get('currentDeliveryWarehouse')

  rendered: ->
    runInitExportTracker()