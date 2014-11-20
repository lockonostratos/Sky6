Deps.autorun ->
  Template.returns.saleList = Schema.sales.find({status: true}).fetch()
  if Session.get 'currentReturn'
    Template.returns.saleDetailList = Schema.saleDetails.find({sale: Session.get('currentReturn').sale}).fetch()
    Template.returns.returnDetailList = Schema.returnDetails.find({returns: Session.get('currentReturn')._id}).fetch()
  Template.returns.returnsList = Schema.returns.find({}).fetch()

_.extend Template.returnss,
  returnCollection: Schema.returns.find()
  returnDetailCollection: Schema.returnDetails.find()
  formatSearchSale: (item) -> "#{item.orderCode}"
  formatSearchReturn: (item) -> "#{item.returnCode}"
  formatSearchProduct: (item) -> "#{item.product}"

  events:
    'click .createReturns': (event, template) ->
      if template.find(".returnCode").value.length > 0 and template.find(".comment").value.length > 0 and Session.get 'currentSale'
        Schema.returns.insert
          merchant      : Session.get('currentWarehouse').merchant
          warehouse     : Session.get('currentWarehouse')._id
          sale          : Session.get('currentSale')._id
          creator       : Meteor.userId()
          returnCode    : template.find(".returnCode").value
          comment       : template.find(".comment").value
          productSale   : 0
          productQuality: 0
          totalPrice    : 0
          status        : 0
      else
        console.log 'thông tin quá ngắn'

    'click .createReturnDetail': (event, template) ->
      if !Session.get('currentReturn') then console.log 'Loi, Chua chon phieu Return'; return
      if !Session.get('currentProductDetail') then console.log 'Loi, Chua chon Product'; return
      if template.find(".returnQuality").value <= 0 then console.log 'Loi, So nho > 0 hoac khong phai So'; return
      if Session.get('currentReturn').sale != Session.get('currentProductDetail').sale then console.log 'Ma Phieu Sale Khong Trung Khop'; return
      if Session.get('currentReturn').status != 0 then console.log 'Loi, Phieu duoc Xac Nhan hoac Hoan Tat, kho the Add'; return
      returnDetail = Schema.returnDetails.findOne({
        returns       : Session.get('currentReturn')._id
        product       : Session.get('currentProductDetail').product
        productDetail : Session.get('currentProductDetail').productDetail
      })
      if returnDetail then returnQuality = returnDetail.returnQuality else returnQuality = 0
      if (Session.get('currentProductDetail').quality - returnQuality) < template.find(".returnQuality").value then console.log 'So luong tra lon hon so luong co'; return
      totalPrice = parseInt(template.find(".returnQuality").value) * Session.get('currentProductDetail').price
      discountCash = totalPrice * Session.get('currentProductDetail').discountPercent
      finalPrice = totalPrice - discountCash
      if returnDetail
        Schema.returnDetails.update returnDetail._id, $inc: {
          returnQuality : parseInt(template.find(".returnQuality").value)
          discountCash  : discountCash
          finalPrice    : finalPrice
        },(e,r) ->
          if r then Schema.returns.update returnDetail.returns, $inc: {
            productQuality : parseInt(template.find(".returnQuality").value)
            totalPrice     : finalPrice
          }
      else
        Schema.returnDetails.insert
          returns       : Session.get('currentReturn')._id
          product       : Session.get('currentProductDetail').product
          productDetail : Session.get('currentProductDetail').productDetail
          returnQuality : parseInt(template.find(".returnQuality").value)
          price         : Session.get('currentProductDetail').price
          discountCash  : discountCash
          finalPrice    : finalPrice
          submit        : false
        ,(e,r) ->
          if r
            if Schema.returnDetails.find({returns: Session.get('currentReturn')._id, product: Session.get('currentProductDetail').product}).fetch().length == 1
              Schema.returns.update Session.get('currentReturn')._id, $inc: {
                productSale    : 1
                productQuality : parseInt(template.find(".returnQuality").value)
                totalPrice     : finalPrice
              }
            else
              Schema.returns.update Session.get('currentReturn')._id, $inc: {
                productQuality : parseInt(template.find(".returnQuality").value)
                totalPrice     : finalPrice
              }







    'click .finishReturn': (event, template) ->
      if Session.get('currentReturn').status == 0
        id_return = Session.get('currentReturn')._id
        Schema.returns.update id_return, $set: {status: 1}
        for returns in Schema.returnDetails.find({returns: id_return}).fetch()
          Schema.returnDetails.update returns._id, $set: {submit: true}
        Session.set 'currentReturn', Schema.returns.findOne id_return
      else
        console.log 'Loi, Phieu Da Xac Nhan Tu Quan Ly, Hoac Nhan Vien '

    'click .editReturn': (event, template) ->
      if Session.get('currentReturn').status == 1
        id_return = Session.get('currentReturn')._id
        Schema.returns.update id_return, $set: {status: 0}
        for returns in Schema.returnDetails.find({returns: id_return}).fetch()
          Schema.returnDetails.update returns._id, $set: {submit: false}
        Session.set 'currentReturn', Schema.returns.findOne id_return
      else
        console.log 'Loi, Phieu Da Xac Nhan Tu Quan Ly(ko dc sua)'

    'click .submitReturn': (event, template) ->
      if Session.get('currentReturn').status == 1
        id_return = Session.get('currentReturn')._id
        Schema.returns.update id_return, $set: {status: 2}
        Session.set 'currentReturn', Schema.returns.findOne id_return
        for returnDetail in Schema.returnDetails.find({returns: id_return}).fetch()
          Schema.productDetails.update returnDetail.productDetail, $inc: {
            availableQuality: returnDetail.returnQuality
            inStockQuality  : returnDetail.returnQuality
          }
          Schema.products.update returnDetail.product, $inc: {
            availableQuality: returnDetail.returnQuality
            inStockQuality  : returnDetail.returnQuality
          }
      else
        console.log 'Loi, Phieu Chua Xac Nhan Tu Nhan Vien'

  rendered: ->
    Template.returns.ui = {}
    #------------------------------------------------------------------------------
    Template.returns.ui.selectBoxSale = $(@find '.sl2')
    Template.returns.ui.selectBoxSale.select2
      placeholder: 'CHỌN PHIẾU ORDER'
      query: (query) -> query.callback
        results: _.filter Template.returns.saleList, (item) ->
          item.orderCode.indexOf(query.term) > -1
        text: 'name'
      initSelection: (element, callback) -> callback(Session.get 'currentSale');
      id: '_id'
      formatSelection : Template.returns.formatSearchSale
      formatResult    : Template.returns.formatSearchSale
    .on "change", (e) ->
      Session.set 'currentSale', e.added
    Template.returns.ui.selectBoxSale.select2 "val", Session.get 'currentSale'

    #------------------------------------------------------------------------------
    Template.returns.ui.selectBoxReturns = $(@find '.sl3')
    Template.returns.ui.selectBoxReturns.select2
      placeholder: 'CHỌN PHIẾU RETURN'
      query: (query) -> query.callback
        results: _.filter Template.returns.returnsList, (item) ->
          item.returnCode.indexOf(query.term) > -1
        text: 'name'
      initSelection: (element, callback) -> callback(Session.get 'currentReturn');

      id: '_id'
      formatSelection: Template.returns.formatSearchReturn
      formatResult: Template.returns.formatSearchReturn
    .on "change", (e) ->
      Session.set 'currentReturn', e.added
    Template.returns.ui.selectBoxReturns.select2 "val", Session.get 'currentReturn'


    #------------------------------------------------------------------------------
    Template.returns.ui.selectBoxProductDetail = $(@find '.sl4')
    Template.returns.ui.selectBoxProductDetail.select2
      placeholder: 'CHỌN PHIẾU Product'
      query: (query) -> query.callback
        results: _.filter Template.returns.saleDetailList, (item) ->
          item.product.indexOf(query.term) > -1
        text: 'name'

      initSelection: (element, callback) -> callback(Session.get 'currentProductDetail');

      id: '_id'
      formatSelection: Template.returns.formatSearchProduct
      formatResult: Template.returns.formatSearchProduct
    .on "change", (e) ->
      Session.set 'currentProductDetail', e.added
    Template.returns.ui.selectBoxProductDetail.select2 "val", Session.get 'currentProductDetail'