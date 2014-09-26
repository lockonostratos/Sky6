formatMerchantSearch = (item) -> "#{item.name}" if item
formatWarehouseSearch = (item) -> "#{item.name}" if item
formatfilterDeliverySearch = (item) -> "#{item.display}" if item

runInitDeliveryTracker = (context) ->
  return if Sky.global.deliveryTracker
  Sky.global.deliveryTracker = Tracker.autorun ->
    if Session.get('currentProfile')
      Session.set "availableDeliveryMerchants", Schema.merchants.find({}).fetch()

    if Session.get('availableDeliveryMerchants') and Session.get('currentProfile')
      Session.set "currentDeliveryMerchant", Schema.merchants.findOne(Session.get('currentProfile').currentDeliveryMerchant)

    if Session.get('currentDeliveryMerchant')
      Session.set "availableDeliveryWarehouses", Schema.warehouses.find({merchant: Session.get('currentDeliveryMerchant')._id}).fetch()

    if Session.get('availableDeliveryWarehouses') and Session.get('currentProfile')
      Session.set "currentDeliveryWarehouse", Schema.warehouses.findOne(Session.get('currentProfile').currentDeliveryWarehouse) ? 'skyReset'

    if Session.get("currentDeliveryWarehouse")
      option =
        merchant: Session.get('currentDeliveryMerchant')._id
        warehouse: Session.get('currentDeliveryWarehouse')._id
        status: {$in: [Session.get('currentProfile')?.currentDeliveryFilter]}
      (option.status = {$in: [7]}) if Session.get('currentProfile')?.currentDeliveryFilter == 5
      (option.status = {$in: [5,8]}) if Session.get('currentProfile')?.currentDeliveryFilter == 6
      (option.status = {$in: [6,9]}) if Session.get('currentProfile')?.currentDeliveryFilter == 7
      Session.set "availableDeliveries", Schema.deliveries.find(option).fetch()



Sky.appTemplate.extends Template.delivery,
  deliverry: ->

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

  filterDeliverySelectOption:
    query: (query) -> query.callback
      results: Sky.system.filterDeliveries
      text: 'id'
    initSelection: (element, callback) -> callback _.findWhere(Sky.system.filterDeliveries, {_id: Session.get('currentProfile')?.currentDeliveryFilter})
    formatSelection: formatfilterDeliverySearch
    formatResult: formatfilterDeliverySearch
    placeholder: 'BỘ LỌC'
    minimumResultsForSearch: -1
    changeAction: (e) ->
      Schema.userProfiles.update Session.get('currentProfile')._id, $set:{currentDeliveryFilter: e.added._id}
    reactiveValueGetter: -> _.findWhere(Sky.system.filterDeliveries, {_id: Session.get('currentProfile')?.currentDeliveryFilter})

  deliveryDetailOptions:
    itemTemplate: 'deliveryThumbnail'
    reactiveSourceGetter: -> Session.get('availableDeliveries') ? []
    wrapperClasses: 'detail-grid row'

  rendered: ->
    runInitDeliveryTracker()