runInitTracker = (context) ->
  return if Sky.global.staffManagerTracker
  Sky.global.staffManagerTracker = Tracker.autorun ->
    Meteor.subscribe 'availableRoles'
    console.log Session.get('currentProfile')?.parentMerchant, '<< currentProfile'
    if Session.get('currentProfile')
      Meteor.subscribe 'merchantProfiles', Session.get('currentProfile')?.parentMerchant

formatRoleSelect = (item) -> "#{item.description}" if item


Sky.appTemplate.extends Template.staffManager,
  created: ->
    runInitTracker()
    Session.setDefault('currentRoleSelection', Schema.roles.findOne())
    console.log 'Staff created!'

  roleSelectOptions:
    query: (query) -> query.callback
      results: Schema.roles.find().fetch()
    minimumResultsForSearch: -1
    placeholder: 'CHỌN PHÂN QUYỀN'
    initSelection: (element, callback) -> Session.get('currentRoleSelection')
    changeAction: (e) ->
      console.log 'changing..'
      Session.set('currentRoleSelection', e.added)
    reactiveValueGetter: -> Session.get('currentRoleSelection')
    formatSelection: formatRoleSelect
    formatResult: formatRoleSelect
#
#  staffManagerDetailOptions:
#    itemTemplate: 'roleDetailRow'
#    reactiveResourceGetter: -> Schema.profiles.find()
