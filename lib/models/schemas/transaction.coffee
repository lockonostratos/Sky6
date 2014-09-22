Schema2.transactions = new SimpleSchema
  merchant:
    type: String

  warehouse:
    type: String

  parent:
    type: String

  creator:
    type: String

  owner:
    type: String
    optional: true

  group:
    type: String

  receivable:
    type: Boolean

  dueDay:
    type: Date
    optional: true

  totalCash:
      type: Number

  depositCash:
    type: Number

  debitCash:
    type: Number

  status:
    type: String

  version: {type: Schema.Version}








