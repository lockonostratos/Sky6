Sky.template.extends Template.stockThumbnail,
  colorClass: -> if @inStockQuality > 0 then 'lime' else 'blue'
  formatCurrency: (number) ->
    accounting.formatMoney(number, { symbol: 'VNĐ',  format: "%v %s", precision: 0 })
  formatNumber: (number) -> accounting.formatMoney(number, { format: "%v", precision: 0 })
  pad: (number) ->
    if number < 10 then '0' + number else number
  round: (number) -> Math.round(number)
  canDelete: -> @totalQuality == 0
  events:
    "dblclick .full-desc.trash": ->
      deletingProduct = Schema.products.findOne(@_id)
      Schema.products.remove(@_id) if deletingProduct?.totalQuality == 0