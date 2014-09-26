checkAllowCreate = (context) ->
  name = context.ui.$name.val()

  if name.length > 0
    Session.set('allowCreateNewBranch', true)
  else
    Session.set('allowCreateNewBranch', false)

createBranch = (context) ->
  name = context.ui.$name.val()
  address = context.ui.$address.val()

  Schema.merchants.insert
    parent: Session.get('currentProfile').parentMerchant
    creator: Meteor.userId()
    name: name
    address: address

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
    reactiveSourceGetter: -> Schema.merchants.find({ parent: Session.get('currentProfile').parentMerchant }).fetch()
    wrapperClasses: 'detail-grid row'