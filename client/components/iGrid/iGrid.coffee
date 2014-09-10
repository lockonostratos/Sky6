Sky.template.extends Template.iGrid,
  itemTemplate: -> UI._templateInstance().data.options.itemTemplate
  dataSource: -> UI._templateInstance().data.options.dataSource
  classicalHeader: -> UI._templateInstance().data.options.classicalHeader

Sky.template.extends Template.testDyn,
  events:
    "click a.btn": (event, template) -> console.log 'button clicked!', @name