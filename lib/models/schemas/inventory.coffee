Schema2.inventories = new SimpleSchema
  merchant:
    type: String

  warehouse:
    type: String

  creator:
    type: String

  description:
    type: String

  resolved:
    type: Boolean

  resolveDescription:
    type: String
    optional: true

  detail:
    type: Boolean

# xac nhan nhan vien
  submit:
    type: Boolean

# hoan thanh xac nhan quan ly
  success:
    type: Boolean

  version: { type: Schema.Version }

