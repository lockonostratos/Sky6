formatSaleSearch = (item) -> "#{item.orderCode}" if item


Sky.template.extends Template.returnPopover,
  error:      -> Session.get 'errorReturnPopover'
  returnList:  -> Session.get 'availableReturns'
  currentSale: -> Session.get 'availableReturns'

  productSelectOptions:
    query: (query) -> query.callback
      results: _.filter Session.get('availableSale'), (item) ->
        unsignedTerm = Sky.helpers.removeVnSigns query.term
        unsignedName = Sky.helpers.removeVnSigns item.orderCode

        unsignedName.indexOf(unsignedTerm) > -1
      text: 'name'
    initSelection: (element, callback) -> callback()
    formatSelection: formatSaleSearch
    formatResult: formatSaleSearch
    id: '_id'
    placeholder: 'CHỌN PHIẾU BÁN HÀNG'
#    minimumResultsForSearch: -1
    changeAction: (e) -> Template.returnPopover.currentSale = e.added._id
    reactiveValueGetter: ->

  events:
    'click .createReturn': (event, template)->
      returns =
        merchant       : @data.merchant
        warehouse      : @data.warehouse
        creator        : Meteor.userId()
        sale           : Template.returnPopover.currentSale
        returnCode     : "ramdom"
        productSale    : 0
        productQuality : 0
        totalPrice     : 0
        status         : 0

      Schema.returns.insert returns, (e,r)->
        console.log e
        console.log r
        if r
        else
          Session.set 'errorReturnPopover', 'Có lỗi trong quá trình tạo'

    'click .removeProvider': (event, template)->
      Schema.returns.remove @_id


  rendered: ->