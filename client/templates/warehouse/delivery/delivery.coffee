formatMerchantSearch = (item) -> "#{item.name}" if item
formatWarehouseSearch = (item) -> "#{item.name}" if item
formatfilterDeliverySearch = (item) -> "#{item.display}" if item

runInitDeliveryTracker = (context) ->
  return if Sky.global.deliveryTracker
  Sky.global.deliveryTracker = Tracker.autorun ->
    if Session.get('currentProfile')
      Session.set "availableDeliveryMerchants", Schema.merchants.find({
        $or:
          [
            {_id: Session.get('currentProfile').parentMerchant}
            {parent: Session.get('currentProfile').parentMerchant}
          ]
      }).fetch()

    if Session.get('availableDeliveryMerchants') and Session.get('currentProfile')
      Session.set "currentDeliveryMerchant", Schema.merchants.findOne(Session.get('currentProfile').currentDeliveryMerchant)

    if Session.get('currentDeliveryMerchant')
      Session.set "availableDeliveryWarehouses", Schema.warehouses.find({merchant: Session.get('currentDeliveryMerchant')._id}).fetch()

    if Session.get('availableDeliveryWarehouses') and Session.get('currentProfile')
      Session.set "currentDeliveryWarehouse", Schema.warehouses.findOne(Session.get('currentProfile').currentDeliveryWarehouse) ? 'skyReset'

    if Session.get("currentDeliveryWarehouse") && Session.get('deliveryFilter')
      option =
        merchant: Session.get('currentDeliveryMerchant')._id
        warehouse: Session.get('currentDeliveryWarehouse')._id
      switch Session.get('deliveryFilter')
        when "selected" then deliveryFilter = {status: 1}
        when "working" then deliveryFilter = {status: {$in: [2,3,4,5,6,8,9]}}
        when "done" then deliveryFilter = {status: {$in: [7,10]}}
      Session.set 'filteredDeliveries', Schema.deliveries.find({$and:[option,deliveryFilter]},Sky.helpers.defaultSort()).fetch()


Sky.appTemplate.extends Template.delivery,
  activeDeliveryFilter: (status)-> return 'active' if Session.get('deliveryFilter') is status
  created: -> Session.setDefault('deliveryFilter', 'working')
  rendered: -> runInitDeliveryTracker()
  events:
    "click [data-filter]": (event, template) ->
      $element = $(event.currentTarget)
      Session.set 'deliveryFilter', $element.attr("data-filter")

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

  deliveryDetailOptions:
    itemTemplate: 'deliveryThumbnail'
    reactiveSourceGetter: -> Session.get('filteredDeliveries') ? []
    wrapperClasses: 'detail-grid row'

