_.extend Template.home,
  engineName: 'Sky5 Engine!'
  productCollection: Schema.products.find({})
  productTableSettings: -> return {
    useFontAwesome: true
    fields: [
      { key: 'creator', label: 'người tạo' }
      { key: 'name', label: 'sản phẩm' }
      { key: 'productCode', label: 'mã vạch' }
      { key: 'skulls', label: 'skulls' }
      { key: 'price', label: 'giá bán' }
      { key: 'quality', label: 'tồn kho' }
    ]
  }
  rendered: ->
    console.log "Home is showing up, awesome!"; return
  events:
    'click input': -> console.log 'Fuck YOU!'
    'click h1': -> console.log 'text clicked'