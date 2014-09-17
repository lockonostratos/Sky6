Sky.template.extends Template.returnProductThumbnail,
  colorClasses: 'none'
  formatCurrency: (number) ->
    accounting.formatMoney(number, { symbol: 'VNĐ',  format: "%v %s", precision: 0 })
  formatNumber: (number) -> accounting.formatMoney(number, { format: "%v", precision: 0 })
  pad: (number) ->
    if number < 10 then '0' + number else number
  round: (number) -> Math.round(number)
  events:
    "dblclick .full-desc.trash": -> Schema.returnDetails.remove(@_id)