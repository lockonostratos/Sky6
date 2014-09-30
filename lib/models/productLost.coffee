Schema.add 'productLosts', class ProductLost
  @new: (warehouse, inventoryDetail)->
    option =
      merchant      : warehouse.merchant
      warehouse     : warehouse._id
      creator       : Meteor.userId()
      product       : inventoryDetail.product
      productDetail : inventoryDetail.productDetail
      inventory     : inventoryDetail.inventory
      name          : inventoryDetail.name
      skulls        : inventoryDetail.skulls
      lostQuality   : inventoryDetail.lostQuality