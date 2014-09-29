checkAllowCreate = (context) ->
  fullName = context.ui.$fullName.val()

  if fullName.length > 0
    Session.set('allowCreateNewCustomer', true)
  else
    Session.set('allowCreateNewCustomer', false)

createCustomer = (context) ->
  fullName = context.ui.$fullName.val()
  phone = context.ui.$phone.val()
  address = context.ui.$address.val()
  dateOfBirth = context.ui.$dateOfBirth.data('datepicker').dates[0]

  Schema.customers.insert
    creator: Meteor.userId()
    name: fullName
    phone: phone
    address: address
    currentMerchant: Session.get('currentProfile').currentMerchant
    parentMerchant: Session.get('currentProfile').parentMerchant

   resetForm(context)

resetForm = (context) -> $(item).val('') for item in context.findAll("[name]")

Sky.appTemplate.extends Template.customerManager,
  allowCreate: -> if Session.get('allowCreateNewCustomer') then 'btn-success' else 'btn-default disabled'
  created: ->
    Session.setDefault('allowCreateNewCustomer', false)

  events:
    "input input": (event, template) -> checkAllowCreate(template)
    "click #createCustomerAccount": (event, template) -> createCustomer(template)

  customerDetailOptions:
    itemTemplate: 'customerThumbnail'
    reactiveSourceGetter: -> Schema.customers.find().fetch()
    wrapperClasses: 'detail-grid row'

