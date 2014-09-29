calculateOriginalQuality = (context) ->
  if context.lock == context.submit == false then return (Schema.productDetails.findOne(context.productDetail))?.instockQuality ? 0
  if context.lock != context.submit == false then return context.originalQuality
  if context.lock == context.submit != false then return (Schema.productDetails.findOne(context.productDetail))?.instockQuality ? 0

calculateSaleQuality = (context) ->
  if context.lock == context.submit == false then return context.saleQuality
  if context.lock != context.submit == false
    saleDetails = Schema.saleDetails.find(
      $and:
        [
          productDetail: context.productDetail
          status       : true
          exportDate   : {$gte: context.lockDate}
        ]).fetch()

    count = 0
    for detail in saleDetails
      count += detail.quality
    if count != context.saleQuality
      realQuality = context.realQuality - (count - context.saleQuality)
      Schema.inventoryDetails.update context._id, $set: {saleQuality: count, realQuality: realQuality}
    return count

  if context.lock == context.submit != false
    saleDetails = Schema.saleDetails.find(
      $and:
        [
          productDetail: context.productDetail
          status       : true
          exportDate   : {$gte: context.submitDate}
        ]).fetch()
    count = 0
    for detail in saleDetails
      count += detail.quality
    if count != context.saleQuality then (Schema.inventoryDetails.update context._id, $set: {saleQuality: count})
    return count

calculateLostQuality = (context) ->
  if context.lock == context.submit == false then return context.lostQuality
  if context.lock != context.submit == false then return context.lostQuality
  if context.lock == context.submit != false then return context.lostQuality
calculateDate = (context) ->
  if context.lock == context.submit == false then return context.version.createdAt
  if context.lock != context.submit == false then return context.lockDate
  if context.lock == context.submit != false then return context.submitDate

calculateRealQuality = (context) ->
  if context.lock == context.submit == false then return 0
  if context.lock != context.submit == false
    context.realQuality



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



Sky.template.extends Template.inventoryProductThumbnail,
  colorClasses: 'none'
  originalQuality: -> calculateOriginalQuality(@)
  saleQuality: -> calculateSaleQuality(@)
#  lostQuality: -> calculateLostQuality(@)
  date: -> calculateDate(@)
  status: ->
    if @lock == @submit == false then return 'New'
    if @lock != @submit == false then return 'Locked'
    if @lock == @submit != false then return 'Submited'

  realQualityOptions: -> {
    parentContext: @
    reactiveSetter: (val) ->
      if @parentContext.lock != @parentContext.submit == false  and @parentContext.success == false
        option={}
        maxQuality = @parentContext.originalQuality - @parentContext.saleQuality
        if val < maxQuality
          option.realQuality = val
          option.lostQuality = maxQuality - val
        else
          option.realQuality = maxQuality
          option.lostQuality = 0
        Schema.inventoryDetails.update @parentContext._id, $set: option
    reactiveValue: -> @parentContext.realQuality ? 0
    #TODO : Chưa cập nhật dc max value (gia tri thay doi, ko cap nhat)
    reactiveMax: -> @parentContext.originalQuality - @parentContext.saleQuality
    reactiveMin: -> 0
    reactiveStep: -> 1
  }

  events:
    "dblclick .fa.fa-lock": (event, template)->
      if @lock == @submit == @success == false
        productDetail = Schema.productDetails.findOne(@productDetail)
        Schema.inventoryDetails.update @_id, $set: {
          lock: true
          lockDate: new Date
          originalQuality: productDetail.instockQuality
          realQuality    : productDetail.instockQuality
          saleQuality    : 0
          lostQuality    : 0
        }

    "dblclick .fa.fa-check": (event, template)->
      if @lock != @submit == @success == false
        productDetail = Schema.productDetails.findOne(@productDetail)
        Schema.inventoryDetails.update @_id, $set: {
          submit: true
          submitDate: new Date
        }

    "dblclick .fa.fa-reply": (event, template)->
      if @lock == @submit != @success == false
        Schema.inventoryDetails.update @_id, $set: {
          submit      : false
          realQuality : @originalQuality - @saleQuality - @lostQuality
        }
  #      if @lock != @submit == false
  #        productDetail = Schema.productDetails.findOne(@productDetail)
  #        Schema.inventoryDetails.update @_id, $set: {
  #          lock: false
  #          originalQuality: productDetail.instockQuality
  #          realQuality    : 0
  #          saleQuality    : 0
  #          lostQuality    : 0
  #        }
