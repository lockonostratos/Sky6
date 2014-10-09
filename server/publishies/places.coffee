Meteor.publish 'users', -> Meteor.users.find({})
Meteor.users.allow
  insert: -> true
  update: -> true
  remove: -> true

Meteor.publish 'merchants', -> Schema.merchants.find({})
Schema.merchants.allow
  insert: -> true
  update: -> true
  remove: -> true

Meteor.publish 'warehouses', -> Schema.warehouses.find({})
Schema.warehouses.allow
  insert: -> true
  update: -> true
  remove: -> true


Meteor.publish 'customers', -> Schema.customers.find({})
Schema.customers.allow
  insert: -> true
  update: -> true
  remove: -> true

#Meteor.publish 'customerDetails', -> Schema.customerDetails.find({})
#Schema.customerDetails.allow
#  insert: -> true
#  update: -> true
#  remove: -> true


Meteor.publish 'metroSummaries', -> Schema.metroSummaries.find({})
Schema.metroSummaries.allow
  insert: -> true
  update: -> true
  remove: -> true

Meteor.publish 'tests', -> Schema.tests.find({})
Schema.tests.allow
  insert: -> true
  update: -> true
  remove: -> true