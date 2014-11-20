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

  totalPrice:
    type: Number

  finalPrice:
    type: Number

  styles:
    type: String
    optional: true

  color:
    type: String
    optional: true

  version: { type: Schema.Version }

