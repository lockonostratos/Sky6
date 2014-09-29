Schema.add 'saleExports', class SaleExport
  @new: (sale ,saleDetail)->
    option =
      merchant      : sale.merchant
      warehouse     : sale.warehouse
      creator       : Meteor.userId()
      sale          : sale._id
      product       : saleDetail.product
      productDetail : saleDetail.productDetail
      name          : saleDetail.name
      skulls        : saleDetail.skulls
      qualityExport : saleDetail.quality




