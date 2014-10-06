toggleExtra = (name, context, mode) ->
  currentExtra = context.ui.extras[name]
  return if !currentExtra
  if mode then currentExtra.$element.show() else currentExtra.$element.hide()
  Sky.helpers.reArrangeLayout()

class Sky.appTemplate
  @extends: (source, destination) ->
    exceptions = ['ui', 'rendered', 'destroyed']
    source[name] = value for name, value of destination when !_(exceptions).contains(name)

    rendered = ->
      @ui = {}; self = @
      @ui[name] = @find(value) for name, value of destination.ui when typeof value is 'string'

      for item in @findAll("[name]")
        $item = $(item)
        alias = $item.attr('name')
        @ui[alias] = item
        @ui["$#{alias}"] = $item

      extras = @findAll(".editor-row.extra[name]")
      @ui.extras = {}
      for extra in extras
        $extra = $(extra)
        name = $extra.attr('name')
        visible = $extra.attr('visibility') ? false
        $extra.show() if visible
        @ui.extras[name] = { visibility: visible, $element: $extra }

      @ui.extras.toggleExtra = (name, mode = true) -> toggleExtra(name, self, mode)

      @$("[data-toggle='tooltip']").tooltip({container: 'body'})
      for item in @findAll("input[binding='datePicker']")
        $item = $(item)
        options = {}
        options.language = "vi"
        options.todayHighlight = true if $item.attr('todayHighlight') is "true"

        $(item).datepicker options

      @ui.switches = {}
      for item in @findAll("[binding='switch']")
        $item = $(item)
        alias = $item.attr('name')
        @ui.switches[alias] = new Switchery(item)

      $(item).attr('maxlength', 120) for item in @findAll("input:not([maxlength])")
      Sky.helpers.reArrangeLayout()

      destination.rendered.apply(@, arguments) if destination.rendered

    destroyed = ->
      @$("[data-toggle='tooltip']").tooltip('destroy')

      destination.destroyed.apply(@, arguments) if destination.destroyed

    source.rendered = rendered
    source.destroyed = destroyed
    source

class Sky.template
  @extends: (source, destination) ->
    exceptions = ['ui', 'rendered']
    source[name] = value for name, value of destination when !_(exceptions).contains(name)

    rendered = ->
      if destination.ui
        @ui = {}
        @ui[name] = @find(value) for name, value of destination.ui when typeof value is 'string'

      destination.rendered.apply(@, arguments) if destination.rendered

    source.rendered = rendered
    source