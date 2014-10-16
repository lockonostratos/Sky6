Schema.add 'transactionDetails', class TransactionDetail
  @newByTransaction: (transaction)->
    option=
      merchant    : transaction.merchant
      warehouse   : transaction.warehouse
      transaction : transaction._id
      totalCash   : transaction.totalCash
      depositCash : transaction.depositCash
      debitCash   : transaction.debitCash
    option._id = Schema.transactionDetails.insert option
    option


