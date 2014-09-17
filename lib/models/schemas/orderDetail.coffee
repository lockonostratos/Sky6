Schema2.orderDetails = new SimpleSchema
  order:
    type: String

  product:
    type: String

  name:
    type: String
    optional: true

  skulls:
    type: [String]
    optional: true

  color:
    type: String
    optional: true

  quality:
    type: Number

  price:
    type: Number

  discountCash:
    type: Number

  discountPercent:
    type: Number
    decimal: true
    optional: true

  tempDiscountPercent:
    type: Number
    decimal: true
    optional: true

  totalPrice:
    type: Number

  finalPrice:
    type: Number

  styles:
    type: String
    optional: true

  version: { type: Schema.Version }

Schema.add 'orderDetails'