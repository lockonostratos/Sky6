Schema2.customers = new SimpleSchema
#co the luu mang [String] tai [0] la merchant tao, [1] la parent[0], [2] parent [1]
  parentMerchant:
    type: String
    optional: true

  currentMerchant:
    type: String

  creator:
    type: String

  areaMerchant:
    type: String
    optional: true

  name:
    type: String

  companyName:
    type: String
    optional: true

  phone:
    type: String

  address:
    type: String
    optional: true

  email:
    type: String
    optional: true

  sex:
    type: Boolean
    optional: true

  version: { type: Schema.Version }

Schema.add 'customers'
