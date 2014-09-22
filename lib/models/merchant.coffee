Schema.add 'merchants', class Merchant
  addAccount: (option, creator, currentWarehouse = null) ->
      option.merchant = @id
      option.creator = creator
      option.currentWarehouse = currentWarehouse if currentWarehouse
      Accounts.createUser option

  addUser: (option, creator, currentWarehouse = null)  ->
    @addAccount(option, creator, currentWarehouse)

  addBranch: (option) ->
    option.parent = @id
    Schema.merchants.insert option

  addWarehouse: (option) ->
    option.merchant = @id
    Schema.warehouses.insert option

  addProvider: (option) ->
    option.merchant = @id
    Schema.providers.insert option

  addSkull: (option) ->
    option.merchant = @id
    Schema.skulls.insert option

  addProduct: (option) ->
    option.merchant = @id
    option.totalQuality = 0
    option.availableQuality = 0
    option.instockQuality = 0
    Schema.products.insert option

  addCustomer: (option) ->
    option.currentMerchant = @id
    if @data.parent
      option.parentMerchant = @data.parent
    else
      option.parentMerchant = @id
    Schema.customers.insert option

  #option: warehouse, creator, description
  #productDetails: product, importQuality, importPrice, provider?, exprire?
  import: (option, productDetails) ->
    try
      transaction = new System.Transaction ["productDetails", "imports"]

      option.merchant = @id
      option.systemTransaction = transaction.id
      newImport = Schema.imports.insert option
      providers = Schema.providers.find({merchant: @id}).fetch()
      for productDetail in productDetails
        product = Schema.products.findOne productDetail.product
        if !product then throw 'Không tìm thấy Product'


        productDetail.import = newImport
        productDetail.merchant = @id
        productDetail.warehouse = option.warehouse
        productDetail.creator = option.creator
        productDetail.provider = providers[Math.floor(Math.random() * providers.length)]._id

        productDetail.availableQuality = productDetail.importQuality
        productDetail.instockQuality = productDetail.importQuality
        productDetail.systemTransaction = transaction.id

        Schema.productDetails.insert productDetail, (error, result) ->
          if error then throw 'Sai thông tin sản phẩm'

        Schema.products.update productDetail.product,
          $inc:
            totalQuality    : productDetail.importQuality
            availableQuality: productDetail.importQuality
            instockQuality  : productDetail.importQuality
          $set:
            provider: productDetail.provider
            importPrice: productDetail.importPrice
    catch e
      transaction.rollBack()
      console.log e
      #@updateProductQualities productDetail


  #PRIVATES------------------------------------
  updateProductQualities: (detail) ->
    product = Schema.products.findOne detail.product
    #TODO: implement this section