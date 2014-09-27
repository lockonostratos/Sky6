Schema2.sales = new SimpleSchema
  merchant:
    type: String

  warehouse:
    type: String

  creator:
    type: String

  seller:
    type: String

  buyer:
    type: String

  orderCode:
    type: String

  productCount:
    type: Number

  saleCount:
    type: Number

  return:
    type: Boolean
    optional: true

  returnCount:
    type: Number

  returnQuality:
    type: Number

  delivery:
    type: String
    optional: true

  paymentMethod:
    type: Number

  billDiscount:
    type: Boolean

  discountCash:
    type: Number

  totalPrice:
    type: Number

  finalPrice:
    type: Number

  deposit:
    type: Number

  paymentsDelivery:
    type: Number

  debit:
    type: Number

  status:
    type: Boolean

  success:
    type: Boolean
#----------------------------------------
  currentReturn:
    type: String
    optional: true

  currentProductDetail:
    type: String
    optional: true

  currentQuality:
    type: Number
    optional: true

#----------------------------------------

  version: { type: Schema.Version }

