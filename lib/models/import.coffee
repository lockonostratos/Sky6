Schema.add 'imports', class Import
  addImportDetails: ->
    try
      importDetails = Schema.importDetails.find({import:@id}).fetch()
      console.log importDetails
      for importDetail in importDetails
        product = Schema.products.findOne importDetail.product
        if !product then throw 'Không tìm thấy Product
'
      for importDetail in importDetails
        productDetail={}
        productDetail.import = @id
        productDetail.merchant = @data.merchant
        productDetail.warehouse = @data.warehouse
        productDetail.product = importDetail.product
        productDetail.importQuality = importDetail.importQuality
        productDetail.availableQuality = importDetail.importQuality
        productDetail.instockQuality = importDetail.importQuality
        productDetail.importPrice = importDetail.importPrice

        Schema.productDetails.insert productDetail, (error, result) ->
          if error then throw 'Sai thong Tin San Pham'

        Schema.products.update importDetail.product,
          $inc:
            totalQuality    : importDetail.importQuality
            availableQuality: importDetail.importQuality
            instockQuality  : importDetail.importQuality

      for importDetail in importDetails
        Schema.importDetails.remove(importDetail._id)
      Schema.imports.update @id, $set:{finish: true}
    catch e
      console.log e



