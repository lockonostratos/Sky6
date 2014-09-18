Schema2.transactionDetails = new SimpleSchema
  merchant:
    type: String

  warehouse:
    type: String

  transaction:
    type: String

  totalCash:
    type: Number

  depositCash:
    type: Number

  debitCash:
    type: Number

  description:
    type: String
    optional: true

  version: {type: Schema.Version}

Schema.add 'transactionDetails'






