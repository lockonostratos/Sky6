Schema.add 'productDetails', class ProductDetail
  @newProductDetail: (imports, importDetail)->
    option =
      import           : imports._id
      merchant         : imports.merchant
      warehouse        : imports.warehouse
      product          : importDetail.product
      importQuality    : importDetail.importQuality
      availableQuality : importDetail.importQuality
      instockQuality   : importDetail.importQuality
      importPrice      : importDetail.importPrice
    option




