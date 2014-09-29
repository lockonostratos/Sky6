checkAllowCreate = (context) ->
  name = context.ui.$name.val()

  if name.length > 0
    Session.set('allowCreateNewBranch', true)
  else
    Session.set('allowCreateNewBranch', false)

createWarehouse = (context) ->
  name = context.ui.$name.val()
  address = context.ui.$address.val()

  Schema.warehouse.insert
    parent: Session.get('currentProfile').parentMerchant
    creator: Meteor.userId()
    name: name
    address: address

  resetForm(context)

resetForm = (context) -> $(item).val('') for item in context.findAll("[name]")

Sky.appTemplate.extends Template.warehouseManager,
  allowCreate: -> if Session.get('allowCreateNewBranch') then 'btn-success' else 'btn-default disabled'
  created: ->  Session.setDefault('allowCreateNewBranch', false)

  productSelectOptions:
    query: (query) -> query.callback
      results: _.filter Session.get('availableProducts'), (item) ->
        unsignedTerm = Sky.helpers.removeVnSigns query.term
        unsignedName = Sky.helpers.removeVnSigns item.name

        unsignedName.indexOf(unsignedTerm) > -1 || item.productCode.indexOf(unsignedTerm) > -1
      text: 'name'
    initSelection: (element, callback) -> callback(Schema.products.findOne(Session.get('currentImport')?.currentProduct))
    formatSelection: formatImportProductSearch
    formatResult: formatImportProductSearch
    placeholder: 'CHỌN SẢN CHI NHÁNH'
    hotkey: 'return'
    changeAction: (e) ->
      option =
        currentProduct     : e.added._id
        currentProvider    : e.added.provider ? 'skyReset'
        currentQuality     : 1
        currentImportPrice : e.added.importPrice ? 0
      if e.added.price > 0
        Schema.imports.update(Session.get('currentImport')._id, $set: option, $unset: {currentPrice: ""})
      else
        option.currentPrice = e.added.importPrice ? 0
        Schema.imports.update(Session.get('currentImport')._id, {$set: option})
      Session.set 'currentProductInstance', Schema.products.findOne(e.added._id)
    reactiveValueGetter: -> Session.get('currentImport')?.currentProduct

  warehouseDetailOptions:
    itemTemplate: 'merchantThumbnail'
    reactiveSourceGetter: -> Schema.merchants.find({ parent: Session.get('currentProfile').parentMerchant }).fetch()
    wrapperClasses: 'detail-grid row'



  events:
    "input input": (event, template) -> checkAllowCreate(template)
    "click #createBranch": (event, template) -> createWarehouse(template)


