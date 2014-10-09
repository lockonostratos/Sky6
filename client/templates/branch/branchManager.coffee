checkAllowCreate = (context) ->
  name = context.ui.$name.val()

  if name.length > 0
    if _.findWhere(Session.get("availableMerchant"), {name: name})
      Session.set('allowCreateNewBranch', false)
    else
      Session.set('allowCreateNewBranch', true)
  else
    Session.set('allowCreateNewBranch', false)

createBranch = (context) ->
  name = context.ui.$name.val()
  address = context.ui.$address.val()
  if Schema.merchants.findOne({name: name})
    console.log 'Chi Nhanh Ton Tai'
  else
    newBranch = Schema.merchants.insert
      parent: Session.get('currentProfile').parentMerchant
      creator: Meteor.userId()
      name: name
      address: address
    Schema.warehouses.insert
      parentMerchant    : Session.get('currentProfile').parentMerchant
      merchant          : newBranch
      creator           : Meteor.userId()
      name              : 'Kho Chính'
      isRoot            : true
      checkingInventory : false

    resetForm(context)

resetForm = (context) -> $(item).val('') for item in context.findAll("[name]")

Sky.appTemplate.extends Template.branchManager,
  allowCreate: -> if Session.get('allowCreateNewBranch') then 'btn-success' else 'btn-default disabled'
  created: ->  Session.setDefault('allowCreateNewBranch', false)
  events:
    "input input": (event, template) -> checkAllowCreate(template)
    "click #createBranch": (event, template) -> createBranch(template)


  branchDetailOptions:
    itemTemplate: 'merchantThumbnail'
    reactiveSourceGetter: -> Session.get("availableMerchant") ? []
    wrapperClasses: 'detail-grid row'