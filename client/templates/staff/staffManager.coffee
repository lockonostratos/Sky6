formatRoleSelect = (item) -> "#{item.name}" if item
formatBranchSelect = (item) -> "#{item.name}" if item
formatWarehouseSelect = (item) -> "#{item.name}" if item

resetForm = (context) ->
  $(item).val('') for item in context.findAll("[name]")
  Session.set('currentRoleSelection', [])

checkAllowCreate = (template) ->
  email = template.ui.$email.val()
  password = template.ui.$password.val()
  confirm = template.ui.$confirm.val()
  fullName = template.ui.$fullName.val()
  if Meteor.users.findOne({'emails.address': email}) then return Session.set('allowCreateStaffAccount', false)
  if email.length > 0 and password.length > 0 and confirm.length > 0 and fullName.length > 0 and password is confirm
    if _.findWhere(Session.get('availableUserProfile'), {fullName: fullName})
      Session.set('allowCreateStaffAccount', false)
    else
      Session.set('allowCreateStaffAccount', true)
  else
    Session.set('allowCreateStaffAccount', false)

createStaffAccount = (template)->
  dateOfBirth = template.ui.$dateOfBirth.data('datepicker').dates[0]
  startWorkingDate = template.ui.$startWorkingDate.data('datepicker').dates[0]
  email = template.ui.$email.val()
  password = template.ui.$password.val()
  fullName = template.ui.$fullName.val()
  unless Meteor.users.findOne({'emails.address': email}) || Schema.userProfiles.findOne({fullName: fullName})
    roles = []
    if Session.get('currentRoleSelection')?.length > 0
      roles.push role.name for role in Session.get('currentRoleSelection')
    newProfile =
      parentMerchant    : Session.get("currentProfile").parentMerchant
      currentMerchant   : Session.get("createStaffBranchSelection")._id
      currentWarehouse  : Session.get("createStaffWarehouseSelection")._id
      fullName          : fullName
      systemVersion     : Schema.systems.findOne().version

    newProfile.roles = roles if roles.length > 0
    newProfile.dateOfBirth = dateOfBirth if dateOfBirth
    newProfile.startWorkingDate = startWorkingDate if startWorkingDate
    newProfile.gender = Session.get("createStaffGenderSelection") if fullName

    Meteor.call "createMerchantAccount", email, password, newProfile
    #      Meteor.call "createMerchantAccount",
    #        email: template.ui.$email.val()
    #        password: template.ui.$password.val()

    newMemberName = fullName ? email
    Notification.newMemberJoined(newMemberName, Session.get("merchantPackages").companyName)
    resetForm(template)



runInitTracker = (context) ->
  return if Sky.global.staffManagerTracker
  Sky.global.staffManagerTracker = Tracker.autorun ->

    if Session.get('currentProfile')
      Meteor.subscribe 'merchantRoles', Session.get('currentProfile').parentMerchant
      Meteor.subscribe 'merchantProfiles', Session.get('currentProfile').parentMerchant

    Session.set 'createStaffBranchSelection', Session.get('currentMerchant') if Session.get('currentMerchant')
    Session.set 'createStaffWarehouseSelection', Session.get('currentWarehouse') if Session.get('currentWarehouse')

Sky.appTemplate.extends Template.staffManager,
  allowCreate: -> if Session.get('allowCreateStaffAccount') then 'btn-success' else 'btn-default disabled'

  created: ->
    runInitTracker()
    Session.setDefault("createStaffGenderSelection", false)
    Session.setDefault('allowCreateStaffAccount', false)
    Session.setDefault('currentRoleSelection', [])

  rendered: ->
    Sky.global.staffManagerTemplateInstance = @
    @ui.$dateOfBirth.datepicker
      language: "vi"

    @ui.$startWorkingDate.datepicker
      language: "vi"
      todayHighlight: true

  events:
    "input input": (event, template) -> checkAllowCreate(template)
    "change [name='genderMode']": (event, template) ->
      Session.set("createStaffGenderSelection", event.target.checked)

    "click #createStaffAccount": (event, template) -> createStaffAccount(template)

    "blur #email": (event, template)->
      $email = $(template.find("#email"))
      if $email.val().length > 0
        unless Sky.helpers.regEx($email.val()) then $email.notify('Tên đăng nhập không hợp lệ')



  roleSelectOptions:
    query: (query) -> query.callback
      results: Schema.roles.find().fetch()
    initSelection: (element, callback) -> callback Session.get('currentRoleSelection')
    changeAction: (e) ->
      currentRoles = Session.get('currentRoleSelection')
      currentRoles = currentRoles ? []

      currentRoles.push e.added if e.added
      if e.removed
        removedItem = _.findWhere(currentRoles, {_id: e.removed._id})
        currentRoles.splice currentRoles.indexOf(removedItem), 1

      Session.set('currentRoleSelection', currentRoles)
    reactiveValueGetter: -> Session.get('currentRoleSelection')
    formatSelection: formatRoleSelect
    formatResult: formatRoleSelect
    others:
      multiple: true
      maximumSelectionSize: 3

  branchSelectOptions:
    query: (query) -> query.callback
      results: Schema.merchants.find().fetch()
    initSelection: (element, callback) -> callback Session.get('createStaffBranchSelection')
    changeAction: (e) ->
      Session.set('createStaffBranchSelection', e.added)
    reactiveValueGetter: -> Session.get('createStaffBranchSelection')
    formatSelection: formatBranchSelect
    formatResult: formatBranchSelect

  warehouseSelectOptions:
    query: (query) -> query.callback
      results: Schema.warehouses.find({merchant: Session.get('currentProfile').currentMerchant}).fetch()
    initSelection: (element, callback) -> callback Session.get('createStaffWarehouseSelection')
    changeAction: (e) ->
      Session.set('createStaffWarehouseSelection', e.added)
    reactiveValueGetter: -> Session.get('createStaffWarehouseSelection')
    formatSelection: formatWarehouseSelect
    formatResult:    formatWarehouseSelect

  staffManagerDetailOptions:
    itemTemplate: 'roleDetailRow'
    reactiveSourceGetter: -> Session.get('availableUserProfile') ? []
    wrapperClasses: 'detail-grid row'


