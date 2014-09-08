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