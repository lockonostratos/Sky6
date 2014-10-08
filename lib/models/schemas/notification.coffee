Schema2.notifications = new SimpleSchema
  sender:
    type: String
    optional: true

  receiver:
    type: String
    optional: true

  message:
    type: String

  notificationType:
    type: String

  characteristic:
    type: String
    optional: true

  seen:
    type: Boolean
    defaultValue: false

  confirmed:
    type: Boolean
    defaultValue: false

  version: { type: Schema.Version }