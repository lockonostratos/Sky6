checkAllowCreate = (context) ->
  fullName = context.ui.$fullName.val()
  phone = context.ui.$phone.val()

  if fullName.length > 0 and phone.length > 0
    if _.findWhere(Session.get("availableCustomers"), {name: fullName, phone: phone})
      Session.set('allowCreateNewCustomer', false)
    else
      Session.set('allowCreateNewCustomer', true)
  else
    Session.set('allowCreateNewCustomer', false)

createCustomer = (context) ->
  fullName = context.ui.$fullName.val()
  phone = context.ui.$phone.val()
  address = context.ui.$address.val()
  dateOfBirth = context.ui.$dateOfBirth.data('datepicker').dates[0]

  if Schema.customers.findOne({
    name: fullName
    phone: phone
    currentMerchant: Session.get('currentProfile').currentMerchant})
    console.log 'Trùng tên khách hàng'
  else
    Schema.customers.insert
      creator: Meteor.userId()
      name: fullName
      phone: phone
      address: address
      currentMerchant : Session.get('currentProfile').currentMerchant
      parentMerchant  : Session.get('currentProfile').parentMerchant
      gender          : Session.get('genderNewCustomer')

     resetForm(context)

resetForm = (context) -> $(item).val('') for item in context.findAll("[name]")

Sky.appTemplate.extends Template.customerManager,
  allowCheck: -> return "display: none" unless Session.get('allowCreateNewCustomer')
  allowCreate: -> if Session.get('allowCreateNewCustomer') then 'btn-success' else 'btn-default disabled'
  created: ->
    Session.setDefault('allowCreateNewCustomer', false)
    Session.setDefault('genderNewCustomer', false)

  events:
    "input input": (event, template) -> checkAllowCreate(template)
    "click #createCustomerAccount": (event, template) -> createCustomer(template)

  customerDetailOptions:
    itemTemplate: 'customerThumbnail'
    reactiveSourceGetter: -> Session.get("availableCustomers") ? []
    wrapperClasses: 'detail-grid row'

