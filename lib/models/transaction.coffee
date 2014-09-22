Schema.add 'transactions', class Transaction
  @newBySale: (sale)->
    option =
      merchant    : sale.merchant
      warehouse   : sale.warehouse
      parent      : sale._id
      creator     : sale.seller
      owner       : sale.buyer
      group       : 'sale'
      receivable  : true
      totalCash   : sale.finalPrice
      depositCash : sale.deposit
      debitCash   : sale.debit
    if sale.paymentMethod == 0
      option.dueDay = new Date()
      option.status = 'closed'
    else
  #    transaction.dueDay = new Date()
      option.status = 'tracking'
    option._id = Schema.transactions.insert option
    option

  @newByImport: (imports)->
    option =
      merchant    : imports.merchant
      warehouse   : imports.warehouse
      parent      : imports._id
      creator     : Meteor.userId()
      group       : 'import'
      receivable  : false
      totalCash   : imports.totalPrice
      depositCash : imports.deposit
      debitCash   : imports.debit

    if imports.debit == 0
      option.dueDay = new Date()
      option.status = 'closed'
    else
      option.status = 'tracking'

    option._id = Schema.transactions.insert option
    option