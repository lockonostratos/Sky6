formatProductSearch = (item) -> "#{item.name} [#{item.skulls}]" if item
formatSellerSearch = (item) -> "#{item.emails[0].address}" if item
formatCustomerSearch = (item) -> "#{item.name}" if item
formatpaymentMethodSearch = (item) -> "#{item.display}" if item

reloadOrderDetail = (template, disCash)->
  quality         = template.find(".quality").value         = calculationValueNumber(template.find(".quality").value, 1, 100)
  price           = template.find(".price").value           = calculationValueNumber(template.find(".price").value, 0)
  totalPrice      = template.find(".totalPrice").value      = quality * price
  if disCash
    discountCash    = template.find(".discountCash").value    = calculationValueNumber(template.find(".discountCash").value, 0, totalPrice)
    discountPercent = template.find(".discountPercent").value = discountCash/(totalPrice/100)
  else
    discountPercent = template.find(".discountPercent").value = calculationValueNumber(template.find(".discountPercent").value, 0, 100)
    discountCash    = template.find(".discountCash").value = (totalPrice/100)*discountPercent
  template.find(".finalPrice").value = totalPrice - discountCash

calculationValueNumber= (value, min, max)->
  temp = parseInt(value); min = parseInt(min); max = parseInt(max)
  return min if !temp || !temp || temp < min || max == min
  return max if max and temp > max
  return temp

maxQuality = ->
  qualityProduct = Session.get('currentProductInstance')?.availableQuality if Session.get('currentProductInstance')
  qualityOrderDetail = _.findWhere(Session.get('currentOrderDetails'), {product: Session.get('currentOrder').currentProduct})?.quality ? 0
  max = qualityProduct - qualityOrderDetail
  max

newDeliver = ->
  option =
    contactName: null
    contactPhone: null
    deliveryAddress: null
    deliveryDate: null
    comment: null

calculateTotalPrice = -> Session.get('currentOrder')?.currentPrice * Session.get('currentOrder')?.currentQuality
calculatePercentDiscount = -> Math.round(Session.get('currentOrder')?.currentDiscount*100/(Session.get('currentOrder')?.currentPrice * Session.get('currentOrder')?.currentQuality))
calculateCashDiscount = (percentage)-> Math.floor(calculateTotalPrice() * (percentage / 100))

Session.set('dummyMax', 5)
Session.set('dummyQuality', 10)

runInitTracker = (context) ->
  return if Sky.global.saleTracker
  Sky.global.saleTracker = Tracker.autorun ->
    if Session.get('currentMerchant')
      Session.set "availableStaffSale", Meteor.users.find({}).fetch()
      if Session.get('currentMerchant').parent
        merchant = Session.get('currentMerchant').parent
      else
        merchant = Session.get('currentMerchant')._id
      Session.set "availableCustomerSale", Schema.customers.find({parentMerchant: merchant}).fetch()

    if Session.get('currentWarehouse') and Session.get('currentProfile')?.currentOrder
      orderHistory =  Schema.orders.find({
        merchant: Session.get('currentMerchant')._id
        warehouse: Session.get('currentWarehouse')._id
        creator: Meteor.userId()
      }).fetch()
      Session.set 'orderHistory', orderHistory
      if orderHistory.length > 0
        order = _.findWhere(orderHistory, {_id: Session.get('currentProfile').currentOrder})
        if order
          Session.set 'currentOrder', order
        else
          Session.set 'currentOrder', orderHistory[0]
      else
        Order.createOrderAndSelect()

    if Session.get('currentOrder')
      Session.set 'currentOrderDetails', Schema.orderDetails.find({order: Session.get('currentOrder')._id}).fetch()
      Session.set 'currentProductInstance', Schema.products.findOne(Session.get('currentOrder').currentProduct)

      Session.set 'currentProductMaxTotalPrice', calculateTotalPrice()
      Session.set 'currentProductMaxQuality', maxQuality()
      Session.set 'currentProductDiscountPercent', calculatePercentDiscount()

    if Session.get('currentOrder')?.buyer and Session.get('currentMerchant')?.parentMerchant
      buyer = Schema.customers.findOne({
        _id: Session.get('currentOrder').buyer
        parentMerchant: Session.get('currentMerchant').parentMerchant
      })
      (Session.set 'currentCustomerSale', buyer) if buyer

    if Sky.global.salesTemplateInstance
      if Session.get('currentOrder')?.paymentsDelivery == 0 || Session.get('currentOrder')?.paymentsDelivery == 2
        Sky.global.salesTemplateInstance.ui.extras.toggleExtra 'delivery', false
      else
        Sky.global.salesTemplateInstance.ui.extras.toggleExtra 'delivery'

Sky.appTemplate.extends Template.sales,
  order: -> Session.get('currentOrder')

  delivery: ->
    if Session.get('currentOrder')?.paymentsDelivery == 1
      return {
        contactName:     Session.get('currentOrder').contactName
        contactPhone:    Session.get('currentOrder').contactPhone
        deliveryAddress: Session.get('currentOrder').deliveryAddress
        deliveryDate:    Session.get('currentOrder').deliveryDate
        comment:         Session.get('currentOrder').comment
        }
    else
      return {}
  currentFinalPrice: -> (Session.get('currentOrder')?.currentPrice * Session.get('currentOrder')?.currentQuality) - Session.get('currentOrder')?.currentDiscountCash
  currentOrderPercentDiscount: ->
    if Session.get('currentOrder')?.discountCash == 0
      return 0
    else
      return Math.round(Session.get('currentOrder')?.discountCash/Session.get('currentOrder')?.totalPrice*100)
  currentDebit: ->
    return 0 if Session.get('currentOrder')?.paymentMethod == 1
    if Session.get('currentOrder')?.paymentMethod == 0
      return Session.get('currentOrder')?.currentDeposit - Session.get('currentOrder')?.finalPrice
  formatNumber: (number) -> accounting.formatNumber(number)

  tabOptions:
    source: 'orderHistory'
    currentSource: 'currentOrder'
    caption: 'tabDisplay'
    key: '_id'
    createAction: -> Order.createOrderAndSelect()
    destroyAction: (instance) -> Order.removeAll(instance._id)
    navigateAction: (instance) -> UserProfile.update {currentOrder: instance._id}

  productSelectOptions:
    query: (query) -> query.callback
      results: _.filter Session.get('availableProducts'), (item) ->
        unsignedTerm = Sky.helpers.removeVnSigns query.term
        unsignedName = Sky.helpers.removeVnSigns item.name

        unsignedName.indexOf(unsignedTerm) > -1 || item.productCode.indexOf(unsignedTerm) > -1
      text: 'name'
    initSelection: (element, callback) -> callback(Schema.products.findOne(Session.get('currentOrder')?.currentProduct))
    formatSelection: formatProductSearch
    formatResult: formatProductSearch
    id: '_id'
    placeholder: 'CHỌN SẢN PHẨM'
#    minimumResultsForSearch: -1
    hotkey: 'return'
    changeAction: (e) ->
      Schema.orders.update Session.get('currentOrder')._id,
        $set:
          currentProduct        : e.added._id
          currentQuality        : Number(1)
          currentPrice          : e.added.price
          currentDiscountCash   : Number(0)
          currentDiscountPercent: Number(0)
    reactiveValueGetter: -> Session.get('currentOrder')?.currentProduct

  customerSelectOptions:
    query: (query) -> query.callback
      results: _.filter Session.get("availableCustomerSale"), (item) ->
        unsignedTerm = Sky.helpers.removeVnSigns query.term
        unsignedName = Sky.helpers.removeVnSigns item.name

        unsignedName.indexOf(unsignedTerm) > -1
      text: 'name'
    initSelection: (element, callback) -> callback(Schema.customers.findOne(Session.get('currentOrder')?.buyer))
    formatSelection: formatCustomerSearch
    formatResult: formatCustomerSearch
    id: '_id'
    placeholder: 'CHỌN NGƯỜI MUA'
    changeAction: (e) ->
      if customer = Schema.customers.findOne(e.added._id)
        option = newDeliver()
        if Session.get('currentOrder')?.paymentsDelivery == 1
          option.buyer = customer._id
          option.contactName     = customer.name ? null
          option.contactPhone    = customer.phone ? null
          option.deliveryAddress = customer.address ? null
        option.tabDisplay = Sky.helpers.respectName(customer.name, customer.gender)
      else
        console.log 'Sai customer'; return
      Schema.orders.update(Session.get('currentOrder')._id, {$set: option})
    reactiveValueGetter: -> Session.get('currentOrder')?.buyer

  sellerSelectOptions:
    query: (query) -> query.callback
      results: _.filter Session.get("availableStaffSale"), (item) ->
        result = false
        for email in item.emails
          if email.address.indexOf(query.term) > -1 then (result = true; break)
        result
      text: 'email'
    initSelection: (element, callback) ->
      currentSeller = Session.get('currentOrder')?.seller ? Meteor.userId()
      callback Meteor.users.findOne(currentSeller)
    formatSelection: formatSellerSearch
    formatResult: formatSellerSearch
    id: '_id'
    placeholder: 'CHỌN NGƯỜI BÁN'
    changeAction: (e) -> Schema.orders.update(Session.get('currentOrder')._id, {$set: {seller: e.added._id}})
    reactiveValueGetter: -> Session.get('currentOrder')?.seller

  paymentMethodSelectOption:
    query: (query) -> query.callback
      results: Sky.system.paymentMethods
      text: 'id'
    initSelection: (element, callback) -> callback _.findWhere(Sky.system.paymentMethods, {_id: Session.get('currentOrder')?.paymentMethod})
    formatSelection: formatpaymentMethodSearch
    formatResult: formatpaymentMethodSearch
    placeholder: 'CHỌN SẢN PTGD'
    minimumResultsForSearch: -1
    changeAction: (e) ->
      if e.added._id == 0
        option =
          paymentMethod  : e.added._id
          currentDeposit : Session.get('currentOrder').finalPrice
          deposit        : Session.get('currentOrder').finalPrice
          debit          : 0
      if e.added._id == 1
        option =
          paymentMethod  : e.added._id
          currentDeposit : 0
          deposit        : 0
          debit          : Session.get('currentOrder').finalPrice
      Schema.orders.update(Session.get('currentOrder')._id, {$set: option})
    reactiveValueGetter: -> _.findWhere(Sky.system.paymentMethods, {_id: Session.get('currentOrder')?.paymentMethod})

  paymentsDeliverySelectOption:
    query: (query) -> query.callback
      results: Sky.system.paymentsDeliveries
      text: 'id'
    initSelection: (element, callback) -> callback _.findWhere(Sky.system.paymentsDeliveries, {_id: Session.get('currentOrder')?.paymentsDelivery})
    formatSelection: formatpaymentMethodSearch
    formatResult: formatpaymentMethodSearch
    placeholder: 'CHỌN SẢN PTGD'
    minimumResultsForSearch: -1
    changeAction: (e) -> Schema.orders.update(Session.get('currentOrder')._id, {$set: {paymentsDelivery: e.added._id}})
    reactiveValueGetter: -> _.findWhere(Sky.system.paymentsDeliveries, {_id: Session.get('currentOrder')?.paymentsDelivery})

  billDiscountSelectOption:
    query: (query) -> query.callback
      results: Sky.system.billDiscounts
      text: 'id'
    initSelection: (element, callback) -> callback _.findWhere(Sky.system.billDiscounts, {_id: Session.get('currentOrder')?.billDiscount})
    formatSelection: formatpaymentMethodSearch
    formatResult: formatpaymentMethodSearch
    placeholder: 'CHỌN SẢN PTGD'
    minimumResultsForSearch: -1
    changeAction: (e) ->
      order = Order.findOne(Session.get('currentOrder')._id)
      option = {billDiscount: e.added._id}
      option.discountCash = 0 if option.billDiscount
      option.discountPercent = 0 if option.billDiscount
      Schema.orders.update(Session.get('currentOrder')._id, {$set: option})
      Sky.global.reCalculateOrder(Session.get('currentOrder')._id)

    reactiveValueGetter: -> _.findWhere(Sky.system.billDiscounts, {_id: Session.get('currentOrder')?.billDiscount})

  saleDetailOptions:
    itemTemplate: 'saleProductThumbnail'
    reactiveSourceGetter: -> Session.get('currentOrderDetails')
    wrapperClasses: 'detail-grid row'

  qualityOptions:
    reactiveSetter: (val) ->
      option = {}
      option.currentQuality = val
      if val > 0 && Session.get('currentOrder').currentPrice > 0
        option.currentDiscountPercent = Math.round(Session.get('currentOrder').currentDiscountCash/(val * Session.get('currentOrder').currentPrice)*100)
      else
        option.currentDiscountCash    = 0
        option.currentDiscountPercent = 0

      Schema.orders.update(Session.get('currentOrder')._id, {$set: option}) if Session.get('currentOrder')
    reactiveValue: -> Session.get('currentOrder')?.currentQuality ? 0
    reactiveMax: -> Session.get('currentProductMaxQuality') ? 1
    reactiveMin: -> 0
    reactiveStep: -> 1

  priceOptions:
    reactiveSetter: (val)->
      Schema.orders.update(Session.get('currentOrder')._id, {$set: {currentPrice: val}}) if Session.get('currentOrder')
    reactiveValue: -> Session.get('currentOrder')?.currentPrice ? 0
    reactiveMax: -> 999999999
    reactiveMin: -> Session.get('currentProductInstance')?.price ? 0
    reactiveStep: -> 1000

  discountCashOptions:
    reactiveSetter: (val)->
      option = {}
      option.currentDiscountCash = val
      if val > 0
        option.currentDiscountPercent = Math.round(val/(Session.get('currentOrder').currentQuality * Session.get('currentOrder').currentPrice)*100)
      else
        option.currentDiscountPercent = 0

      Schema.orders.update(Session.get('currentOrder')._id, {$set: option}) if Session.get('currentOrder')
    reactiveValue: -> Session.get('currentOrder')?.currentDiscountCash ? 0
    reactiveMax: ->  Session.get('currentProductMaxTotalPrice') ? 0
    reactiveMin: -> 0
    reactiveStep: -> 1000
    others:
      forcestepdivisibility: 'none'

  discountPercentOptions:
    reactiveSetter: (val) ->
      option = {}
      option.currentDiscountPercent = val
      if val > 0
        option.currentDiscountCash = Math.round((Session.get('currentOrder').currentQuality * Session.get('currentOrder').currentPrice)/100*val)
      else
        option.currentDiscountCash = 0

      Schema.orders.update(Session.get('currentOrder')._id, {$set: option}) if Session.get('currentOrder')
    reactiveValue: -> Session.get('currentOrder')?.currentDiscountPercent ? 0
    reactiveMax: -> 100
    reactiveMin: -> 0
    reactiveStep: -> 1

  depositOptions:
    reactiveSetter: (val) ->
      if val >= Session.get('currentOrder').finalPrice
        option=
          currentDeposit  : val
          paymentMethod   : 0
          deposit         : Session.get('currentOrder').finalPrice
          debit           : 0

        Schema.orders.update(Session.get('currentOrder')._id, {$set: option}) if Session.get('currentOrder')
      else
        option=
          currentDeposit  : val
          paymentMethod   : 1
          deposit         : val
          debit           : Session.get('currentOrder').finalPrice - val
        Schema.orders.update(Session.get('currentOrder')._id, {$set: option}) if Session.get('currentOrder')
    reactiveValue: -> Session.get('currentOrder')?.currentDeposit ? 0
    reactiveMax: -> 999999990
    reactiveMin: -> 0
    reactiveStep: -> 1000
    others:
      forcestepdivisibility: 'none'

  billCashDiscountOptions:
    reactiveSetter: (val)->
      if Session.get('currentOrder')?.billDiscount
        option = {}
        option.discountCash = val
        if val > 0
          if val == Session.get('currentOrder').finalPrice
            option.discountPercent = 100
          else
            option.discountPercent = val*100/Session.get('currentOrder').finalPrice
        else
          option.discountPercent = 0
      Schema.orders.update(Session.get('currentOrder')._id, {$set: option}) if Session.get('currentOrder')
    reactiveValue: -> Session.get('currentOrder')?.discountCash ? 0
    reactiveMax: ->
      if Session.get('currentOrder')?.billDiscount
        Session.get('currentOrder')?.totalPrice ? 0
      else
        Session.get('currentOrder')?.discountCash ? 0
    reactiveMin: ->
      if Session.get('currentOrder')?.billDiscount
        0
      else
        Session.get('currentOrder')?.discountCash ? 0
    reactiveStep: -> 1000
    others:
      forcestepdivisibility: 'none'

  billPercentDiscountOptions:
    reactiveSetter: (val)->
      if Session.get('currentOrder')?.billDiscount
        option = {}
        option.discountPercent = val
        if val > 0
          if val == 100
            option.discountCash = Session.get('currentOrder').finalPrice
          else
            option.discountCash = Math.round(Session.get('currentOrder').finalPrice*option.discountPercent/100)
        else
          option.discountCash = 0
      Schema.orders.update(Session.get('currentOrder')._id, {$set: option}) if Session.get('currentOrder')
    reactiveValue: -> Math.round(Session.get('currentOrder')?.discountPercent*100)/100 ? 0
    reactiveMax: ->
      if Session.get('currentOrder')?.billDiscount
        100
      else
        Session.get('currentOrder')?.discountPercent ? 0
    reactiveMin: ->
      if Session.get('currentOrder')?.billDiscount
        0
      else
        Session.get('currentOrder')?.discountPercent ? 0
    reactiveStep: -> 0.01
    others:
      forcestepdivisibility: 'none'
      decimals: 2

  events:
    'click .addOrderDetail': (event, template)-> Order.addOrderDetail(Session.get('currentOrder')._id)
    'click .finish': (event, template)-> console.log Order.finishOrder(Session.get('currentOrder')._id)
    'blur .contactName': (event, template)->
      if template.find(".contactName").value.length > 1
        Schema.orders.update(Session.get('currentOrder')._id, {$set: {
          contactName: template.find(".contactName").value
        }})
      else
        template.find(".contactName").value = Session.get('currentOrder').contactName

    'blur .contactPhone': (event, template)->
      if template.find(".contactPhone").value.length > 1
        Schema.orders.update(Session.get('currentOrder')._id, {$set: {
          contactPhone: template.find(".contactPhone").value
        }})
      else
        template.find(".contactPhone").value = Session.get('currentOrder').contactPhone


    'blur .deliveryAddress': (event, template)->
      if template.find(".deliveryAddress").value.length > 1
        Schema.orders.update(Session.get('currentOrder')._id, {$set: {
          deliveryAddress: template.find(".deliveryAddress").value
        }})
      else
        template.find(".deliveryAddress").value = Session.get('currentOrder').deliveryAddress

#    'blur .deliveryDate': (event, template)->
#      deliveryDate = template.ui.$deliveryDate.data('datepicker').dates[0]
#      if template.find(".deliveryDate").value.length > 1
#        Schema.orders.update(Session.get('currentOrder')._id, {$set: {
#          deliveryDate: template.find(".deliveryDate").value
#        }})
#      else
#        console.log 'Name is null'

    'blur .comment': (event, template)->
      if template.find(".comment").value.length > 1
        Schema.orders.update(Session.get('currentOrder')._id, {$set: {
          comment: template.find(".comment").value
        }})
      else
        template.find(".comment").value = Session.get('currentOrder').comment

    "change [name='advancedMode']": (event, template) ->
      Sky.global.salesTemplateInstance.ui.extras.toggleExtra 'advanced', event.target.checked

  rendered: ->
    Sky.global.salesTemplateInstance = @
    runInitTracker()
    @ui.$deliveryDate.datepicker
      language: "vi"




