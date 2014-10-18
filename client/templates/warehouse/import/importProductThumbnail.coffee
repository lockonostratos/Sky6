Sky.template.extends Template.importProductThumbnail,
  colorClasses: 'none'
  formatCurrency: (number) ->
    accounting.formatMoney(number, { symbol: 'VNĐ',  format: "%v %s", precision: 0 })
  formatNumber: (number) -> accounting.formatMoney(number, { format: "%v", precision: 0 })
  pad: (number) ->
    if number < 10 then '0' + number else number
  round: (number) -> Math.round(number)
  expire: -> if @expire then @expire.toDateString()

  events:
    "dblclick .full-desc.trash": ->
      Schema.importDetails.remove(@_id)
      Sky.global.reCalculateImport(@import)