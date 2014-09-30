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
  lockOriginalQuality:
    type: Number
    optional: true

#so luong trong kho
  originalQuality:
    type: Number
    optional: true

#so luong kiem tra
  realQuality:
    type: Number

#so luong ban khi kiem kho
  saleQuality:
    type: Number
    optional: true

#so luong mat tiem lai dc
  lostQuality:
    type: Number
    optional: true

  resolved:
    type: Boolean

  lock:
    type: Boolean

  lockDate:
    type: Date
    optional: true

  submit:
    type: Boolean

  submitDate:
    type: Date
    optional: true

  success:
    type: Boolean

  successDate:
    type: Date
    optional: true

  status:
    type: Boolean




  version: { type: Schema.Version }

