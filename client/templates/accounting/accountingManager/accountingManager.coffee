formatWarehouseSearch = (item) -> "#{item.name}" if item
checkAllowFilter = (context) ->
  fromDate = context.ui.$fromDate.data('datepicker').dates[0]
  toDate = context.ui.$toDate.data('datepicker').dates[0]

  if !fromDate or !toDate
    Session.set('allowFilterAccounting', true)
  else
    Session.set('allowFilterAccounting', false)

runInitAccountingManagerTracker = (context) ->
  return if Sky.global.accountingManagerTracker
  Sky.global.accountingManagerTracker = Tracker.autorun ->
    if Session.get('currentWarehouse')
      accountingDetails = Schema.sales.find({$and: [
        { $or : [
          {
            warehouse: Session.get('currentWarehouse')._id
            'version.createdAt': {$gt: Session.get('accountingFilterStartDate')}
            'version.createdAt': {$lt: Session.get('accountingFilterToDate')}
            paymentsDelivery: 0
            status: true
            submitted: false
            exported: false
            imported: false
            received: false
          }
          {
            warehouse: Session.get('currentWarehouse')._id
            'version.createdAt': {$gt: Session.get('accountingFilterStartDate')}
            'version.createdAt': {$lt: Session.get('accountingFilterToDate')}
            paymentsDelivery: 1
            status: true
            submitted: false
            exported: false
            imported: false
            received: false
          }
          {
            warehouse: Session.get('currentWarehouse')._id
            'version.createdAt': {$gt: Session.get('accountingFilterStartDate')}
            'version.createdAt': {$lt: Session.get('accountingFilterToDate')}
            paymentsDelivery: 1
            status: true
            submitted: false
            exported: true
            imported: false
            received: true
            success : true
          }
        ]}
      ]}, Sky.helpers.defaultSort(1)).fetch()
      Session.set 'accountingDetails', accountingDetails

Sky.appTemplate.extends Template.accountingManager,

  warehouseSelectOptions:
    query: (query) -> query.callback
      results: _.filter Session.get('availableWarehouses'), (item) ->
        unsignedTerm = Sky.helpers.removeVnSigns query.term
        unsignedName = Sky.helpers.removeVnSigns item.name
        unsignedName.indexOf(unsignedTerm) > -1
    initSelection: (element, callback) -> callback(Session.get('currentWarehouse') ? 'skyReset')
    formatSelection: formatWarehouseSearch
    formatResult: formatWarehouseSearch
    placeholder: 'CHỌN CHI NHÁNH'
    minimumResultsForSearch: -1
    changeAction: (e) ->
      Schema.userProfiles.update Session.get('currentProfile')._id, $set: {currentWarehouse: e.added._id}
    reactiveValueGetter: -> Session.get('currentWarehouse') ? 'skyReset'

  created: ->
    date = new Date();
    firstDay = new Date(date.getFullYear(), date.getMonth(), 1);
    lastDay = new Date(date.getFullYear(), date.getMonth() + 1, 0);
    Session.set('accountingFilterStartDate', firstDay)
    Session.set('accountingFilterToDate', lastDay)

  rendered: ->
    runInitAccountingManagerTracker()
    @ui.$fromDate.datepicker('setDate', Session.get('accountingFilterStartDate'));
    @ui.$toDate.datepicker('setDate', Session.get('accountingFilterToDate'));

  events:
    "click #filterBills": (event, template)->
      Session.set('accountingFilterStartDate', template.ui.$fromDate.data('datepicker').dates[0])
      Session.set('accountingFilterToDate', template.ui.$toDate.data('datepicker').dates[0])

  billDetailOptions:
    itemTemplate: 'accountingManagerThumbnail'
    reactiveSourceGetter: ->  Session.get('accountingDetails') ? []
    wrapperClasses: 'detail-grid row'