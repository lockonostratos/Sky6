Sky.appTemplate.extends Template.transactionManager,
  transactionDetailOptions:
    itemTemplate: 'transactionThumbnail'
    reactiveSourceGetter: -> Schema.transactions.find().fetch()
    wrapperClasses: 'detail-grid row'
