Sky.appTemplate.extends Template.stockManager,
  stockDetailOptions:
    itemTemplate: 'stockThumbnail'
    reactiveSourceGetter: -> Schema.products.find().fetch()
    wrapperClasses: 'detail-grid row'