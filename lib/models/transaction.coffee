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

  @newByReturn: (returns)->
    option =
      merchant    : returns.merchant
      warehouse   : returns.warehouse
      parent      : returns._id
      creator     : returns.creator
      owner       : Schema.sales.findOne(returns.sale).buyer
      group       : 'return'
      receivable  : false
      totalCash   : returns.finallyPrice
      depositCash : returns.finallyPrice
      debitCash   : 0
      dueDay      : new Date()
      status      : 'closed'
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

  recalculateTransaction: (debitCash)->
    if @data.debitCash >= debitCash and @data.status is 'tracking'
      currentDebitCash = @data.debitCash - debitCash
      currentDepositCash = @data.depositCash + debitCash
      if currentDepositCash == @data.totalCash then status = 'closed' else status = 'tracking'
      transactionDetail=
        merchant    : @data.merchant
        warehouse   : @data.warehouse
        transaction : @data._id
        totalCash   : @data.debitCash
        depositCash : debitCash
        debitCash   : (@data.debitCash - debitCash)

      Schema.transactions.update @id, $set:{
        debitCash: currentDebitCash
        depositCash: currentDepositCash
        status: status
      }

      Schema.transactionDetails.insert transactionDetail

      if @data.group is 'sale'
        Schema.sales.update @data.parent, $set:{
          deposit : currentDepositCash
          debit   : currentDebitCash
          status  : false
        }
        MetroSummary.updateMetroSummaryByTransaction(@data.merchant, debitCash)




