Schema2.productDetails = new SimpleSchema
  import:
    type: String
    optional: true

  merchant:
    type: String
    optional: true

  warehouse:
    type: String
    optional: true

  provider:
    type: String
    optional: true

  product:
    type: String
    optional: true

  importQuality:
    type: Number
    optional: true

  availableQuality:
    type: Number
    optional: true

  instockQuality:
    type: Number
    optional: true

  importPrice:
    type: Number
    optional: true

  expire:
    type: Date
    optional: true

  systemTransaction:
    type: String
    optional: true

  version: { type: Schema.Version }



#Schema.ProductDetail.after.insert (userId, doc)->
#  product = Schema.Product.findOne doc.product
#  if product
#    Schema.Product.update doc.product,
#      $inc:
#        totalQuality: doc.importQuality
#        availableQuality: doc.importQuality
#        instockQuality: doc.importQuality
#    , (error, result) -> console.log result; console.log error if error
#
#Schema.ProductDetail.after.remove (userId, doc) ->
#  product = Schema.Product.findOne doc.product
#  if product
#    Schema.Product.update doc.product,
#      $inc:
#        totalQuality: -doc.importQuality
#        availableQuality: -doc.importQuality
#        instockQuality: -doc.importQuality
#    , (error, result) -> console.log result
#
#Schema.ProductDetail.after.update (userId, doc, fieldNames, modifier, options) ->
#  product = Schema.Product.findOne doc.product
#  if product && modifier.$inc
#    console.log "#{modifier.$inc.importQuality}, #{modifier.$inc.availableQuality}, #{modifier.$inc.instockQuality}"
#    Schema.Product.direct.update doc.product,
#      $inc:
#        totalQuality: modifier.$inc.importQuality ? 0
#        availableQuality: modifier.$inc.availableQuality ? 0
#        instockQuality: modifier.$inc.instockQuality ? 0
#    , (error, result) -> console.log result if Meteor.isServer