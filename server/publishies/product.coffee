Meteor.publish 'products', -> Schema.products.find {}
Meteor.publish 'parentProducts', -> Schema.products.find {childProduct: {$exists: true}}, {fields: productCode: 0}
Meteor.publish 'productWith', (options) -> Schema.products.find options

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

Meteor.publish 'productLosts', -> Schema.productLosts.find {}
Schema.productLosts.allow
  insert: -> true
  update: -> true
  remove: -> true