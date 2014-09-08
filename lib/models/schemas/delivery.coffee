Schema2.deliveries = new SimpleSchema
  merchant:
    type: String

  warehouse:
      type: String

  creator:
      type: String

  sale:
    type: String
    optional: true

  deliveryAddress:
    type: String

  contactName:
    type: String
    optional: true

  contactPhone:
    type: String

  deliveryDate:
    type: Date
    optional: true

  comment:
    type: String
    optional: true

  transportationFee:
    type: Number
    optional: true

  shipper:
    type: String
    optional: true

  exporter:
    type: String
    optional: true

  importer:
    type: String
    optional: true

  cashier:
    type: String
    optional: true

  status:
    type: Number

  version: { type: Schema.Version }

Schema.add 'deliveries'
