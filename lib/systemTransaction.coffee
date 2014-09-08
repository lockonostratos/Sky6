class System.Transaction
  constructor: (@documents) -> @id = Meteor.uuid()

  rollBack: ->
    for document in @documents
      collection = Schema[document]
      continue if collection is undefined
      collection.remove { systemTransaction: @id }

#  success: => @destroy()
#  destroy: -> Schema.SystemTransaction.remove @id
