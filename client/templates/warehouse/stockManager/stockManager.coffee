Sky.appTemplate.extends Template.stockManager,

  stockDetailOptions:
    itemTemplate: 'stockThumbnail'
    reactiveSourceGetter: -> Session.get("availableProducts") ? []
    wrapperClasses: 'detail-grid row'