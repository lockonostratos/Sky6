Deps.autorun ->
  Template.warehouse.productList = Schema.products.find({}).fetch()

_.extend Template.warehouse,
  currentProduct: {}
  tabOption:
    name: "Default"
    tabs: [{caption: "tab 1", class: "active"}, {caption: "tab 2"}, {caption: "tab 3"}]
    createAction: =>
      Template.warehouse.tabOption.tabs.push { caption: "new" }
      console.log Template.warehouse.tabOption.tabs
  tabOption2:
    name: "Noo"
    tabs: [{caption: "tab 1", class: "active"}]
    createAction: =>
      Template.warehouse.tabOption.tabs.push { caption: "new" }
      console.log Template.warehouse.tabOption.tabs
  selectNewProduct: ->
    Template.warehouse.ui.selectBox.select2("open")
  addNewProduct: ->
    console.log 'adding new product..'

  formatSearch: (item) -> "#{item.name} [#{item.skulls}]"

  rendered: ->
    Template.warehouse.ui = {}
    Template.warehouse.ui.selectBox = $(@find '.sl2')
    $(document).bind 'keyup', 'return', Template.warehouse.selectNewProduct
    Template.warehouse.ui.selectBox.bind 'keyup', 'ctrl+return', Template.warehouse.addNewProduct

    Template.warehouse.ui.selectBox.select2
      placeholder: 'CHỌN SẢN PHẨM'
      query: (query) -> query.callback
        results: _.filter Template.warehouse.productList, (item) ->
          unsignedTerm = Sky.helpers.removeVnSigns query.term
          unsignedName = Sky.helpers.removeVnSigns item.name

          unsignedName.indexOf(unsignedTerm) > -1 || item.productCode.indexOf(unsignedTerm) > -1
        text: 'name'
      initSelection: (element, callback) -> callback(Template.warehouse.currentProduct);

      id: '_id'
      formatSelection: Template.warehouse.formatSearch
      formatResult: Template.warehouse.formatSearch
    .on "change", (e) ->
      Template.warehouse.currentProduct = e.added
      console.log e.val
    Template.warehouse.ui.selectBox.select2 "val", Template.warehouse.currentProduct

    $(@find '#productPopover').modalPopover
      target: '#popProduct'
      backdrop: true
      placement: 'bottom'

    $(@find '#providerPopover').modalPopover
      target: '#popProvider'
      backdrop: true
      placement: 'bottom'

    $(@find '#customerPopover').modalPopover
      target: '#popCustomer'
      backdrop: true
      placement: 'bottom'


    $(@find '#warehousePopover').modalPopover
      target: '#popWarehouse'
      backdrop: true
      placement: 'bottom'


    $(@find '#skullPopover').modalPopover
      target: '#popSkull'
      backdrop: true
      placement: 'bottom'


    $('.popProvider').popover({
      html: true
      title: 'title'
      content: '#productPopover'
    });

  destroyed: ->
    $(document).unbind 'keyup', Template.warehouse.selectNewProduct
    $(document).unbind 'keyup', Template.warehouse.addNewProduct
    $(@find '.sl2').select2('destroy')

  events:
    "click .tile": (event, template) -> $(template.find '#productAside').modal()
    "click #popProduct": (event, template) -> $(template.find '#productPopover').modalPopover('show')
    "click #popProvider": (event, template) -> $(template.find '#providerPopover').modalPopover('show')
    "click #popCustomer": (event, template) -> $(template.find '#customerPopover').modalPopover('show')
    "click #popWarehouse": (event, template) -> $(template.find '#warehousePopover').modalPopover('show')
    "click #popSkull": (event, template) -> $(template.find '#skullPopover').modalPopover('show')
