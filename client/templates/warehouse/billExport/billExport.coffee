checkAllowFilter = (context) ->
  fromDate = context.ui.$fromDate.data('datepicker').dates[0]
  toDate = context.ui.$toDate.data('datepicker').dates[0]

  if !fromDate or !toDate
    Session.set('allowFilterBills', true)
  else
    Session.set('allowFilterBills', false)


Sky.appTemplate.extends Template.billExport,
  created: ->
    date = new Date();
    firstDay = new Date(date.getFullYear(), date.getMonth(), 1);
    lastDay = new Date(date.getFullYear(), date.getMonth() + 1, 0);
    Session.set('billFilterStartDate', firstDay)
    Session.set('billFilterToDate', lastDay)

  rendered: ->
    @ui.$fromDate.datepicker('setDate', Session.get('billFilterStartDate'));
    @ui.$toDate.datepicker('setDate', Session.get('billFilterToDate'));

  events:
    "click #filterBills": (event, template)->
      Session.set('billFilterStartDate', template.ui.$fromDate.data('datepicker').dates[0])
      Session.set('billFilterToDate', template.ui.$toDate.data('datepicker').dates[0])

  billDetailOptions:
    itemTemplate: 'billExportThumbnail'
    reactiveSourceGetter: ->
      Schema.sales.find({$and: [
        {'version.createdAt': {$gt: Session.get('billFilterStartDate')}}
        {'version.createdAt': {$lt: Session.get('billFilterToDate')}}
      ]}).fetch()
    wrapperClasses: 'detail-grid row'