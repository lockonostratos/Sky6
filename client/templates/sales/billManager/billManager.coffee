formatWarehouseSearch = (item) -> "#{item.name}" if item
checkAllowFilter = (context) ->
  fromDate = context.ui.$fromDate.data('datepicker').dates[0]
  toDate = context.ui.$toDate.data('datepicker').dates[0]

  if !fromDate or !toDate
    Session.set('allowFilterBills', true)
  else
    Session.set('allowFilterBills', false)

runInitBillManagerTracker = (context) ->
  return if Sky.global.billManagerTracker
  Sky.global.billManagerTracker = Tracker.autorun ->
    if Session.get('currentWarehouse')
      currentBillManagerDetails = Schema.sales.find({$and: [
        {warehouse: Session.get('currentWarehouse')._id}
        {'version.createdAt': {$gt: Session.get('billFilterStartDate')}}
        {'version.createdAt': {$lt: Session.get('billFilterToDate')}}
      ]}, Sky.helpers.defaultSort(1)).fetch()
      Session.set 'billManagerDetails', currentBillManagerDetails

Sky.appTemplate.extends Template.billManager,

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
    Session.set('billFilterStartDate', firstDay)
    Session.set('billFilterToDate', lastDay)

  rendered: ->
    runInitBillManagerTracker()
    @ui.$fromDate.datepicker('setDate', Session.get('billFilterStartDate'));
    @ui.$toDate.datepicker('setDate', Session.get('billFilterToDate'));

  events:
    "click #filterBills": (event, template)->
      Session.set('billFilterStartDate', template.ui.$fromDate.data('datepicker').dates[0])
      Session.set('billFilterToDate', template.ui.$toDate.data('datepicker').dates[0])

  billDetailOptions:
    itemTemplate: 'billThumbnail'
    reactiveSourceGetter: -> Session.get('billManagerDetails') ? []

    wrapperClasses: 'detail-grid row'