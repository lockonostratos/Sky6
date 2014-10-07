root = global ? window

extendObject = (source, destination) ->
  exceptions = ['helpers']
  destination[name] = value for name, value of source when !_(exceptions).contains(name)
  destination.prototype[name] = value for name, value of source.prototype

root.Schema =
  add: (name, extensionObj = null) ->
    Schema[name] = new Meteor.Collection name
    Schema[name].helpers(extensionObj.helpers) if extensionObj?.helpers
    Schema[name].attachSchema Schema2[name]
    return if !Model.Base

    singularName = extensionObj.name
    class root[singularName] extends Model.Base
    extendObject extensionObj, root[singularName]
    root[singularName].schema = Schema[name]
    root[singularName].prototype.schema = Schema[name]

root.System = {}
root.Schema2 = {}
root.Model = {}
#  add: (name, schema, extensionObj) ->
#    class root[name] extends Model.Base
#    root[name].schema = schema
#    extendObject extensionObj, root[name]

Schema.Version = new SimpleSchema
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

Schema.Location = new SimpleSchema
  address:
    type: [String]
    optional: true

  areas:
    type: [String]
    optional: true

Schema.ChildProduct = new SimpleSchema
  product:
    type: String

  quality:
    type: Number