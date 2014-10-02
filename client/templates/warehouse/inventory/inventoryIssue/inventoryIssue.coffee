formatMerchantSearch = (item) -> "#{item.name}" if item
formatWarehouseSearch = (item) -> "#{item.name}" if item

runInitInventoryIssueTracker = (context) ->
  return if Sky.global.inventoryIssueTracker
  Sky.global.inventoryIssueTracker = Tracker.autorun ->
      if currentWarehouse = Session.get("inventoryWarehouse")
        inventoryIssue = Schema.productLosts.find({warehouse: currentWarehouse._id}).fetch()
        if inventoryIssue.length > 0 then Session.set "availableInventoryIssue", inventoryIssue
        if inventoryIssue.length == 0 then Session.set "availableInventoryIssue"
      else
        Session.set "availableInventoryIssue"



Sky.appTemplate.extends Template.inventoryIssue,
  merchantSelectOptions:
    query: (query) -> query.callback
      results: _.filter Session.get('allMerchantInventories'), (item) ->
        unsignedTerm = Sky.helpers.removeVnSigns query.term
        unsignedName = Sky.helpers.removeVnSigns item.name
        unsignedName.indexOf(unsignedTerm) > -1
    initSelection: (element, callback) -> callback(Session.get('inventoryMerchant'))
    formatSelection: formatMerchantSearch
    formatResult: formatMerchantSearch
    placeholder: 'CHỌN CHI NHÁNH'
    changeAction: (e) ->
      Schema.userProfiles.update Session.get('currentProfile')._id, $set:
        inventoryMerchant : e.added._id
        inventoryWarehouse: Schema.warehouses.findOne(merchant: e.added._id)?._id  ? 'skyReset'
    reactiveValueGetter: -> Session.get('inventoryMerchant')

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
    reactiveValueGetter: -> Session.get('inventoryWarehouse') ? 'skyReset'

  inventoryIssueOptions:
    itemTemplate: 'inventoryIssueThumbnail'
    reactiveSourceGetter: -> Session.get('availableInventoryIssue') ? []
    wrapperClasses: 'detail-grid row'

  billDetailOptions:
    itemTemplate: 'billThumbnail'
    reactiveSourceGetter: ->
      Schema.sales.find({$and: [
        {'version.createdAt': {$gt: Session.get('inventoryIssueFilterStartDate')}}
        {'version.createdAt': {$lt: Session.get('inventoryIssueFilterToDate')}}
      ]}).fetch()
    wrapperClasses: 'detail-grid row'


  created: ->
    date = new Date();
    firstDay = new Date(date.getFullYear(), date.getMonth(), 1);
    lastDay = new Date(date.getFullYear(), date.getMonth() + 1, 0);
    Session.set('inventoryIssueFilterStartDate', firstDay)
    Session.set('inventoryIssueFilterToDate', lastDay)

  rendered: ->
    runInitInventoryIssueTracker()
    @ui.$fromDate.datepicker('setDate', Session.get('inventoryIssueFilterStartDate'));
    @ui.$toDate.datepicker('setDate', Session.get('inventoryIssueFilterToDate'));

  events:
    "click #filterBills": (event, template)->
      Session.set('inventoryIssueFilterStartDate', template.ui.$fromDate.data('datepicker').dates[0])
      Session.set('inventoryIssueFilterToDate', template.ui.$toDate.data('datepicker').dates[0])
