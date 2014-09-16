Meteor.publish "allUsers", ->
  Meteor.users.find {},
    fields:
      'emails': 1
      'profile.merchant': 1
      'currentOrder': 1
      'currentImport': 1
      'currentWarehouse': 1

Meteor.publish "myProfile", ->
  Schema.userProfiles.find { user: @userId }

Schema.userProfiles.allow
  insert: -> true
  update: -> true
  remove: -> true