Meteor.publish 'orders', -> Schema.orders.find({})
Schema.orders.allow
  insert: -> true
  update: -> true
  remove: -> true

Meteor.publish 'orderDetails', -> Schema.orderDetails.find({})
Schema.orderDetails.allow
  insert: -> true
  update: -> true
  remove: -> true

