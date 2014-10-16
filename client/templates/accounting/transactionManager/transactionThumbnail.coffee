Sky.template.extends Template.transactionThumbnail,
  colorClass: -> if @status is 'closed' then 'lime' else 'pumpkin'
  ownerName: -> Schema.customers.findOne(@owner)?.name
  formatNumber: (number) -> accounting.formatMoney(number, { format: "%v", precision: 0 })
  daysFromNow: -> (new Date) - @dueDay if @dueDay