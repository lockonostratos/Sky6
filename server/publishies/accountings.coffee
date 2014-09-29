Meteor.publish 'transactions', -> Schema.transactions.find({})
Schema.transactions.allow
  insert: -> true
  update: -> true
  remove: -> false

Meteor.publish 'transactionDetails', -> Schema.transactionDetails.find({})
Schema.transactionDetails.allow
  insert: -> true
  update: -> true
  remove: -> false