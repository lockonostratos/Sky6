formatSaleReturnSearch = (item) -> "#{item.orderCode}" if item
formatReturnSearch = (item) -> "#{item.returnCode}" if item
formatReturnProductSearch = (item) ->
  "#{item.name} [#{item.skulls}] - [#{item.discountPercent}% * #{item.quality}]" if item

returnQuality= ->
  findReturnDetail =_.findWhere(Session.get('currentReturnDetails'),{
    productDetail   : Session.get('currentProductDetail').productDetail
    discountPercent : Session.get('currentProductDetail').discountPercent
  })
  if findReturnDetail
    Session.get('currentProductDetail')?.quality - (Session.get('currentProductDetail')?.returnQuality + findReturnDetail.returnQuality)
  else
    Session.get('currentProductDetail')?.quality - Session.get('currentProductDetail')?.returnQuality

runInitReturnsTracker = (context) ->
  return if Sky.global.returnTracker
  Sky.global.returnTracker = Tracker.autorun ->
    if Session.get('currentWarehouse')
      Session.set "availableSales", Schema.sales.find({warehouse: Session.get('currentWarehouse')._id}).fetch()

    if Session.get('currentProfile')?.currentSale
      Session.set 'currentSale', Schema.sales.findOne(Session.get('currentProfile')?.currentSale)

    if Session.get('currentSale')
      Session.set 'currentReturn', Schema.returns.findOne({sale: Session.get('currentSale')._id, status: {$ne: 2}})
      Session.set 'currentSaleProductDetails', Schema.saleDetails.find({sale: Session.get('currentSale')._id}).fetch()

    if Session.get('currentSale')?.currentProductDetail
      Session.set 'currentProductDetail', Schema.saleDetails.findOne(Session.get('currentSale')?.currentProductDetail)

    if Session.get('currentReturn')
      Session.set 'currentReturnDetails', Schema.returnDetails.find({returns: Session.get('currentReturn')._id}).fetch()
    else
      Session.set 'currentReturnDetails'

    if Session.get('currentProductDetail')
      Session.set 'currentMaxQualityReturn', returnQuality()

Sky.appTemplate.extends Template.returns,
  return: -> Session.get('currentSale')?
  hideFinishReturn: -> return "display: none" if Session.get('currentReturn')?.status != 0
  hideEditReturn:   -> return "display: none" if Session.get('currentReturn')?.status != 1
  hideSubmitReturn: -> return "display: none" if Session.get('currentReturn')?.status != 1



  saleSelectOptions:
    query: (query) -> query.callback
      results: _.filter Session.get('availableSales'), (item) ->
        unsignedTerm = Sky.helpers.removeVnSigns query.term
        unsignedName = Sky.helpers.removeVnSigns item.orderCode
        unsignedName.indexOf(unsignedTerm) > -1
      text: 'orderCode'
    initSelection: (element, callback) -> callback(Session.get 'currentSale')
    formatSelection: formatSaleReturnSearch
    formatResult: formatSaleReturnSearch
    id: '_id'
    placeholder: 'CHỌN PHIẾU BÁN HÀNG'
#    minimumResultsForSearch: -1
    changeAction: (e) ->
      Schema.userProfiles.update(Session.get('currentProfile')._id, {$set: {currentSale: e.added._id}})
      if sale = Schema.sales.findOne(e.added._id)
        Session.set 'currentSale', sale
        if returns = Schema.returns.findOne({sale: sale._id})
          Session.set 'currentReturn', returns
          Session.set 'currentReturnDetails', Schema.returnDetails.find({returns: returns._id}).fetch()
        else
          Session.set 'currentReturn'
          Session.set 'currentReturnDetails'
      else
        Session.set 'currentSale'


    reactiveValueGetter: -> Session.get('currentProfile')?.currentSale

  returnProductSelectOptions:
    query: (query) -> query.callback
      results: Session.get('currentSaleProductDetails')
    initSelection: (element, callback) -> callback(Schema.saleDetails.findOne(Session.get('currentSale')?.currentProductDetail))
    formatSelection: formatReturnProductSearch
    formatResult: formatReturnProductSearch
    placeholder: 'CHỌN SẢN PHẨM'
    minimumResultsForSearch: -1
    hotkey: 'return'
    changeAction: (e) -> Schema.sales.update(Session.get('currentSale')._id, {$set: {
      currentProductDetail: e.added._id
      currentQuality: 1
    }})
    reactiveValueGetter: -> Session.get('currentSale')?.currentProductDetail

  returnQualityOptions:
    reactiveSetter: (val) -> Schema.sales.update(Session.get('currentSale')._id, {$set: {currentQuality: val}})
    reactiveValue: -> Session.get('currentSale')?.currentQuality ? 0
    reactiveMax: -> Session.get('currentMaxQualityReturn') ? 0
    reactiveMin: -> 0
    reactiveStep: -> 1

  returnDetailOptions:
    itemTemplate: 'returnProductThumbnail'
    reactiveSourceGetter: -> Session.get('currentReturnDetails')
    wrapperClasses: 'detail-grid row'

  events:
    'click .addReturnDetail': (event, template)-> console.log ReturnDetail.addReturnDetail(Session.get('currentSale')._id)

    'click .finishReturn': (event, template)-> console.log Return.finishReturn(Session.get('currentReturn')._id) if Session.get('currentReturn')

    'click .editReturn': (event, template)-> console.log Return.editReturn(Session.get('currentReturn')._id) if Session.get('currentReturn')

    'click .submitReturn': (event, template)->
      currentSale = Sale.findOne(Session.get('currentSale')._id)
      currentSale.submitReturn()

  rendered: ->
    runInitReturnsTracker()
