Schema2.inventoryDetails = new SimpleSchema
  inventory:
    type: String

  product:
    type: String

  productDetail:
    type: String

  name:
    type: String

  skulls:
    type: [String]

#so luong trong kho
  originalQuality:
    type: Number

#so luong kiem tra
  realQuality:
    type: Number

#so luong ban khi kiem kho
  saleQuality:
    type: Number

#so luong mat tiem lai dc
  lostQuality:
    type: Number

  resolved:
    type: Boolean

  submit:
    type: Boolean

  submitDate:
    type: Date
    denyInsert: true
    optional: true

  success:
    type: Boolean

  version: { type: Schema.Version }

