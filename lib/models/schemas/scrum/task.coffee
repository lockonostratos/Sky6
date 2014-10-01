Schema2.tasks = new SimpleSchema
  creator:
    type: String

  group:
    type: [String]

  description:
    type: String

  priority:
    type: Number

  finishDate:
    type: Date

  status:
    type: String

  version: { type: Schema.Version }

Schema.add 'tasks'