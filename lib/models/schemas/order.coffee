Schema2.orders = new SimpleSchema
  merchant:
    type: String

  warehouse:
    type: String

  creator:
    type: String

  seller:
    type: String
    optional: true

  buyer:
    type: String
    optional: true

  tabDisplay:
    type: String
    optional: true

  orderCode:
    type: String
    optional: true

  productCount:
    type: Number
    optional: true

  saleCount:
    type: Number
    optional: true

  paymentsDelivery:
    type: Number
    optional: true

  delivery:
    type: String
    optional: true

  paymentMethod:
    type: Number
    optional: true

  billDiscount:
    type: Boolean
    optional: true

  discountCash:
    type: Number
    optional: true

  discountPercent:
    type: Number
    decimal: true
    optional: true

  totalPrice:
    type: Number
    optional: true

  finalPrice:
    type: Number
    optional: true

  deposit:
    type: Number
    optional: true

  debit:
    type: Number
    optional: true

  status:
    type: Number

  version: { type: Schema.Version }

#----------------------
  currentProduct:
    type: String
    optional: true

  currentQuality:
    type: Number
    optional: true

  currentPrice:
    type: Number
    optional: true

  currentDiscountCash:
    type: Number
    optional: true

  currentDiscountPercent:
    type: Number
    decimal: true
    optional: true

  currentDeposit:
    type: Number
    optional: true
#----------------------
  contactName:
    type: String
    optional: true

  contactPhone:
    type: String
    optional: true

  deliveryAddress:
    type: String
    optional: true

  deliveryDate:
    type: Date
    optional: true

  comment:
    type: String
    optional: true
#----------------------