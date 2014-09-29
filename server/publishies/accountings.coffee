Meteor.publish 'transactions', -> Schema.transactions.find({})
Schema.imports.allow
  insert: -> true
  update: -> true
  remove: -> false

Meteor.publish 'transactionDetails', -> Schema.transactionDetails.find({})
Schema.imports.allow
  insert: -> true
  update: -> true
  remove: -> false