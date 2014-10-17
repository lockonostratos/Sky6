Schema2.customerQuotes = new SimpleSchema
  name:
    type: String

  position:
    type: String

  avatar:
    type: String

  comment:
    type: String

  version: { type: Schema.Version }

Schema.add 'customerQuotes'