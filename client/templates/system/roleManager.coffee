runInitTracker = (context) ->
  return if Sky.global.staffManagerTracker
  Sky.global.staffManagerTracker = Tracker.autorun ->

    if Session.get('currentProfile')
      Meteor.subscribe 'merchantRoles', Session.get('currentProfile')?.parentMerchant
#      Meteor.subscribe 'merchantProfiles', Session.get('currentProfile')?.parentMerchant

    Session.setDefault 'currentRoleSelection', Schema.roles.findOne()
#    Session.setDefault 'createStaffWarehouseSelection', Session.get('currentWarehouse')

syncSwitchState = (switchery, turnOn) ->
  changeSateHook = switchery.isChecked() isnt turnOn
  switchery.element.click() if changeSateHook

rolesTemplateContext = undefined

formatRoleSelect = (item) -> "#{item.name}" if item

checkAllowCreate = (context) ->
  groupName = context.ui.$newGroupName.val()
  if !groupName or groupName is ''
    Session.set('allowCreateNewRole', false)
    return

  existedRole = Schema.roles.findOne {name: groupName}
  Session.set('allowCreateNewRole', existedRole is undefined)

Sky.appTemplate.extends Template.roleManager,
  allowCreate: -> if Session.get('allowCreateNewRole') then 'btn-success' else 'btn-default disabled'
  permissions: ->
    permissions = []
    for permission, obj of Sky.system.merchantPermissions
      permissions.push obj

    permissions

  created: ->
    runInitTracker()
    Session.setDefault('allowCreateNewRole', false)

  rendered: ->
    @ui.switches = []
    for item in @findAll('.js-switch[key]')
      $item = $(item)

      @ui.switches.push
        key: $item.attr('key')
        val: new Switchery(item)

    rolesTemplateContext = @

  events:
    "input [name='newGroupName']": (event, template) -> checkAllowCreate(template)

    "click #newGroupButton:not(.disabled)": (event, template)->
      groupName = template.ui.$newGroupName.val()

      newRole = Schema.roles.insert
        group: 'merchant'
        name: groupName

      template.ui.$newGroupName.val(''); checkAllowCreate(template)
      Session.set('currentRoleSelection', Schema.roles.findOne(newRole))

    "click #updateButton": (event, template) ->
      return if !Session.get('currentRoleSelection')
      newPermissions = []
      for item in template.ui.switches
        newPermissions.push item.key if item.val.isChecked()

      Schema.roles.update(Session.get('currentRoleSelection')._id, {$set: {permissions: newPermissions}})

  roleSelectOptions:
    query: (query) -> query.callback
      results: Schema.roles.find({}, {sort: {'version.updateAt': -1}}).fetch()
    initSelection: (element, callback) -> callback Session.get('currentRoleSelection')
    changeAction: (e) ->
      Session.set('currentRoleSelection', e.added)
      for item in rolesTemplateContext.ui.switches
        hasThisPermission = _.contains(e.added.permissions, item.key)
        syncSwitchState(item.val, hasThisPermission)

    reactiveValueGetter: -> Session.get('currentRoleSelection')
    formatSelection: formatRoleSelect
    formatResult: formatRoleSelect