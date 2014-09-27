calculateOriginalQuality = (context) ->
  if context.lock == context.submit == false then return Schema.productDetails.findOne(context.productDetail).instockQuality ? 0
  if context.lock != context.submit == false then return context.originalQuality
  if context.lock == context.submit != false
    productDetail = Schema.productDetails.findOne(context.productDetail)
    if productDetail.instockQuality != context.originalQuality
      Schema.inventoryDetails.update context._id, $set: {originalQuality: productDetail.instockQuality}
    return productDetail.instockQuality

calculateSaleQuality = (context) ->
  if context.lock == context.submit == false then return 0
  if context.lock != context.submit == false
    saleDetails = Schema.saleExports.find(
      $and:
        [
          productDetail: context.productDetail
          'version.createdAt': {$gte: context.lockDate}
        ]).fetch()
    count = 0
    for detail in saleDetails
      count += detail.qualityExport
    if count != context.saleQuality
      Schema.inventoryDetails.update context._id, $set: {saleQuality: count}
    return count

  if context.lock == context.submit != false
    saleDetails = Schema.saleExports.find(
      $and:
        [
          productDetail: context.productDetail
          'version.createdAt': {$gte: context.submitDate}
        ]).fetch()
    count = 0
    for detail in saleDetails
      count += detail.qualityExport
    if count != context.saleQuality
      Schema.inventoryDetails.update context._id, $set: {saleQuality: count}
    return count

calculateLostQuality = (context) ->
  if context.lock == context.submit == false then return 0
  if context.lock != context.submit == false
    lostQuality = context.originalQuality - (context.realQuality + context.saleQuality)
    if lostQuality != context.lostQuality
      Schema.inventoryDetails.update context._id, $set: {lostQuality: lostQuality}
    return lostQuality

  if context.lock == context.submit != false
    lostQuality = (context.originalQuality + context.saleQuality) - context.realQuality
    if lostQuality != context.lostQuality
      Schema.inventoryDetails.update context._id, $set: {lostQuality: lostQuality}
    return lostQuality

calculateDate = (context) ->
  if context.lock == context.submit == false then return context.version.createdAt
  if context.lock != context.submit == false then return context.lockDate
  if context.lock == context.submit != false then return context.submitDate

Sky.template.extends Template.inventoryProductThumbnail,
  colorClasses: 'none'
  originalQuality: -> calculateOriginalQuality(@)
  saleQuality: -> calculateSaleQuality(@)
  lostQuality: -> calculateLostQuality(@)
  date: -> calculateDate(@)
  status: ->
    if @lock == @submit == false then return 'New'
    if @lock != @submit == false then return 'Locked'
    if @lock == @submit != false then return 'Submited'



  realQualityOptions: -> {
  parentContext: @
  reactiveSetter: (val, context) ->
    if context.lock != context.submit == false
      Schema.inventoryDetails.update context._id, $set: {realQuality : val}
  reactiveValue: (context) -> @parentContext.realQuality ? 0
  reactiveMax: ->  1000
  reactiveMin: -> 0
  reactiveStep: -> 1
  }

  events:
    "dblclick .fa.fa-lock": (event, template)->
      if @lock == @submit == false
        productDetail = Schema.productDetails.findOne(@productDetail)
        Schema.inventoryDetails.update @_id, $set: {
          lock: true
          lockDate: new Date
          originalQuality: productDetail.instockQuality
          realQuality    : productDetail.instockQuality
          saleQuality    : 0
          lostQuality    : 0
        }
    "dblclick .fa.fa-reply": (event, template)->
      if @lock != @submit == false
        productDetail = Schema.productDetails.findOne(@productDetail)
        Schema.inventoryDetails.update @_id, $set: {
          lock: false
          originalQuality: productDetail.instockQuality
          realQuality    : 0
          saleQuality    : 0
          lostQuality    : 0
        }
      if @lock == @submit != false
        Schema.inventoryDetails.update @_id, $set: {
          submit: false
          lockDate: new Date
        }


    "dblclick .fa.fa-check": (event, template)->
      if @lock != @submit == false
        Schema.inventoryDetails.update @_id, $set: {
          submit: true
          submitDate: new Date
        }
