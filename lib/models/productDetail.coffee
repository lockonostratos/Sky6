Schema.add 'productDetails', class ProductDetail
  @newProductDetail: (imports, importDetail)->
    option =
      import           : imports._id
      merchant         : imports.merchant
      warehouse        : imports.warehouse
      product          : importDetail.product
      importQuality    : importDetail.importQuality
      availableQuality : importDetail.importQuality
      inStockQuality   : importDetail.importQuality
      importPrice      : importDetail.importPrice
      name             : importDetail.name
      skulls           : importDetail.skulls
      checkingInventory: false
    option.expire = importDetail.expire if importDetail.expire
    option




