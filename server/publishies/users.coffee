Meteor.publish "allUsers", ->
  Meteor.users.find {},
    fields:
      'emails': 1
      'profile.merchant': 1
      'currentOrder': 1
      'currentImport': 1
      'currentWarehouse': 1
      'status': 1

Meteor.publish "myProfile", -> Schema.userProfiles.find {user: @userId}
Meteor.publish "merchantProfiles", (merchant) ->
  Schema.userProfiles.find { parentMerchant: merchant }

Schema.userProfiles.allow
  insert: -> true
  update: -> true
  remove: -> true

Meteor.publish "merchantRoles", (merchant) ->
  Schema.roles.find {$or: [{owner: {$exists: false}}, {parentMerchant: merchant}]}

Schema.roles.allow
  insert: -> true
  update: -> true
  remove: -> true