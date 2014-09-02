Schema2.exports = new SimpleSchema
  parentMerchant:
    type: String
    optional: true

  merchant:
    type: String

  warehouse:
    type: String

  targetWarehouse:
    type: String

  creator:
    type: String

  name:
    type: String

  description:
    type: String

  success:
    type: Boolean

  status:
    type: Number

  version: { type: Schema.Version }

Schema.add 'exports'