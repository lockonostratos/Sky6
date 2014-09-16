Schema2.userProfiles = new SimpleSchema
  user:
    type: String

  isRoot:
    type: Boolean

  parent:
    type: Boolean

  merchant:
    type: String

  warehouse:
    type: String

  creator:
    type: String

  currentOrder:
    type: String





Schema.add 'userProfiles'