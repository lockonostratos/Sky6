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

  deliveryType:
    type: Number

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

  debit:
    type: Number

  status:
    type: Boolean
    optional: true

  version: { type: Schema.Version }

Schema.add 'sales'