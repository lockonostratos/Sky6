Sky.template.extends Template.iSelect,
  events:
    "click .select2component": ->
  ui:
    component: ".select2component"
  rendered: ->
    self = @
    $component = $(@ui.component)
    console.log @data.options.name, @ui.component
#    @autoSelectValue = Tracker.autorun ->
#      $component.select2("val", Session.get(self.options.))
