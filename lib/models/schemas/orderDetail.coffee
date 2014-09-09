Schema2.orderDetails = new SimpleSchema
  order:
    type: String

  product:
    type: String

  quality:
    type: Number

  price:
    type: Number

  discountCash:
    type: Number

  discountPercent:
    type: Number
    decimal: true

  tempDiscountPercent:
    type: Number
    decimal: true
    optional: true

  finalPrice:
    type: Number

  version: { type: Schema.Version }

Schema.add 'orderDetails'