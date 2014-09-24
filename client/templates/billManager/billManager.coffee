Sky.appTemplate.extends Template.billManager,
  rendered: ->
    @ui.$fromDate.datepicker('setDate', new Date(Date.now()));
    @ui.$toDate.datepicker('setDate', new Date(Date.now()));

  billDetailOptions:
    itemTemplate: 'billThumbnail'
    reactiveSourceGetter: -> Schema.sales.find().fetch()
    wrapperClasses: 'detail-grid row'

