root = global ? window

Sky.schema2 = {}

Sky.schema2.Version = new SimpleSchema
  createdAt:
    type: Date
    autoValue: ->
      if @isInsert
        return new Date
      else if @isUpsert
        return { $setOnInsert: new Date }
      else
        @unset(); return

  updateAt:
    type: Date
    autoValue: ->
      return new Date() if @isUpdate
      return
    denyInsert: true
    optional: true

Sky.schema2.Location = new SimpleSchema
  address:
    type: [String]
    optional: true

  areas:
    type: [String]
    optional: true

Sky.schema2.ChildProduct = new SimpleSchema
  product:
    type: String

  quality:
    type: Number

class Sky.schema
  class @modelBase
    constructor: (@data) -> @id = @data._id
    @create: (option) -> @schema.insert option
    @findOne: (option) ->
      found = @schema.findOne option
      return new @(found) if found
      return undefined

    @remove: (option) -> @schema.remove option
    @update: (option) -> @schema.update option

  extendObject = (source, destination) ->
    destination[name] = value for name, value of source
    destination.prototype[name] = value for name, value of source.prototype

  register: (name, extensionObj = null) ->
    Sky.schema[name] = new Meteor.Collection name
    Sky.schema[name].attachSchema Sky.schema2[name]

    singularName = extensionObj.name
    class root[singularName] extends Sky.schema.modelBase
    extendObject extensionObj, root[singularName]
    root[singularName].schema = Sky.schema[name]
    root[singularName].prototype.schema = Sky.schema[name]
