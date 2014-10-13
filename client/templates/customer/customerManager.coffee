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

  option =
    creator: Meteor.userId()
    name: fullName
    phone: phone
    address: address
    currentMerchant : Session.get('currentProfile').currentMerchant
    parentMerchant  : Session.get('currentProfile').parentMerchant
    gender          : Session.get('genderNewCustomer')


  if Schema.customers.findOne({
    name: fullName
    phone: phone
    currentMerchant: Session.get('currentProfile').currentMerchant})
    console.log 'Trùng tên khách hàng'
  else
    Schema.customers.insert option, (error, result) ->
      if error
        console.log error
      else
        MetroSummary.updateMetroSummaryBy(['customer'])
    resetForm(context)

resetForm = (context) -> $(item).val('') for item in context.findAll("[name]")

Sky.appTemplate.extends Template.customerManager,
  allowCreate: -> if Session.get('allowCreateNewCustomer') then 'btn-success' else 'btn-default disabled'
  created: ->
    Session.setDefault('allowCreateNewCustomer', false)
    Session.setDefault('genderNewCustomer', true)

  events:
    "input input": (event, template) -> checkAllowCreate(template)
    "click #createCustomerAccount": (event, template) -> createCustomer(template)
    "change [name='genderMode']": (event, template) ->
      Session.set 'genderNewCustomer', event.target.checked

  customerDetailOptions:
    itemTemplate: 'customerThumbnail'
    reactiveSourceGetter: -> Session.get("availableCustomers") ? []
    wrapperClasses: 'detail-grid row'

