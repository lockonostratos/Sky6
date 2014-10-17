Sky.global.merchantWizard = {}

Meteor.startup ->
  Sky.global.merchantWizard.merchantPackages = Schema.merchantPackages.findOne(user: Meteor.userId())

