Meteor.publish 'products', -> Schema.products.find {}
#  Meteor.publishWithRelations
#    handle: this
#    collection: Schema.products
#    filter: {}
#    mappings: [
#      key: 'creator'
#      collection: Meteor.users
#    ]


Schema.products.allow
  insert: -> true
  update: -> true
  remove: -> true

Meteor.publish 'productDetails', -> Schema.productDetails.find {}
Schema.productDetails.allow
  insert: -> true
  update: -> true
  remove: -> true