Meteor.publish 'imports', -> Schema.imports.find({})
Schema.imports.allow
  insert: -> true
  update: -> true
  remove: -> true

Meteor.publish 'importDetails', -> Schema.importDetails.find({})
Schema.importDetails.allow
  insert: -> true
  update: -> true
  remove: -> true


Meteor.publish 'sales', -> Schema.sales.find({})
Schema.sales.allow
  insert: -> true
  update: -> true
  remove: -> true

Meteor.publish 'saleDetails', -> Schema.saleDetails.find({})
Schema.saleDetails.allow
  insert: -> true
  update: -> true
  remove: -> true

Meteor.publish 'deliveries', -> Schema.deliveries.find({})
Schema.deliveries.allow
  insert: -> true
  update: -> true
  remove: -> true

Meteor.publish 'returns', -> Schema.returns.find({})
Schema.returns.allow
  insert: -> true
  update: -> true
  remove: -> true

Meteor.publish 'returnDetails', -> Schema.returnDetails.find({})
Schema.returnDetails.allow
  insert: -> true
  update: -> true
  remove: -> true


Meteor.publish 'skulls', -> Schema.skulls.find({})
Schema.skulls.allow
  insert: -> true
  update: -> true
  remove: -> true

Meteor.publish 'providers', -> Schema.providers.find({})
Schema.providers.allow
  insert: -> true
  update: -> true
  remove: -> true

