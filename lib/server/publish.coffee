Meteor.users.allow
  'update': (userId, options) -> true

Meteor.publish null, () ->
  Meteor.users.find {}, {fields: {roles: 1}}