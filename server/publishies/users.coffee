Meteor.publish "allUsers", ->
  Meteor.users.find {},
    fields:
      'emails': 1
      'profile.merchant': 1
