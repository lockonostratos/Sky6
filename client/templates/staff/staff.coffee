runInitTracker = (context) ->
  return if Sky.global.staffManagerTracker
  Sky.global.staffManagerTracker = Tracker.autorun ->

    if Session.get('currentProfile')
      console.log 'subscribing..'
      Meteor.subscribe 'merchantRoles', Session.get('currentProfile')?.parentMerchant
      Meteor.subscribe 'merchantProfiles', Session.get('currentProfile')?.parentMerchant

    Session.setDefault 'createStaffBranchSelection', Session.get('currentMerchant')
    Session.setDefault 'createStaffWarehouseSelection', Session.get('currentWarehouse')

formatRoleSelect = (item) -> "#{item.description}" if item
formatBranchSelect = (item) -> "#{item.name}" if item
formatWarehouseSelect = (item) -> "#{item.name}" if item

Sky.appTemplate.extends Template.staffManager,
  created: ->
    runInitTracker()

  rendered: ->
    @ui.$dateOfBirth.datepicker
      language: "vi"

    @ui.$startWorkingDate.datepicker
      language: "vi"
      todayHighlight: true

  events:
    "click #createStaffAccount": (event, template) ->
      dateOfBirth = template.ui.$dateOfBirth.val()
      startWorkingDate = template.ui.$startWorkingDate.val()
      email = template.ui.$email.val()
      password = template.ui.$password.val()

      roles = []
      if Session.get('currentRoleSelection')?.length > 0
        roles.push role.name for role in Session.get('currentRoleSelection')
      newProfile =
        parentMerchant: Session.get("currentProfile").parentMerchant
        currentMerchant: Session.get("createStaffBranchSelection")._id
        currentWarehouse: Session.get("createStaffWarehouseSelection")._id

      newProfile.roles = roles if roles.length > 0
      newProfile.dateOfBirth = dateOfBirth if dateOfBirth
      newProfile.startWorkingDate = startWorkingDate if startWorkingDate

      console.log newProfile

      Meteor.call "createMerchantAccount", email, password, newProfile
#      Meteor.call "createMerchantAccount",
#        email: template.ui.$email.val()
#        password: template.ui.$password.val()

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
    reactiveSourceGetter: -> Schema.userProfiles.find().fetch()
    wrapperClasses: 'detail-grid row'


