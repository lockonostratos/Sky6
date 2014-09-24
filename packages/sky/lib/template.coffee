extraHeight = 40;
navbarHeight = 40;

remarginAppHeader = (context) ->
  $header = $(context.find('.app-header'))
  $editor = $(context.find('.app-editor'))
  headerHeight = $header.outerHeight() ? 0
  editorHeight = $editor.outerHeight() ? 0

  rightSideTopMargin = headerHeight + editorHeight;

  $header.css('top', "#{navbarHeight}px")
  $editor.css('top', "#{navbarHeight + headerHeight}px")
  $('#right-side').css('margin-top', "#{rightSideTopMargin}px")

reMarginAppFooter = (context) ->
  $summary = $(context.find('.app-summary'))
  $status = $(context.find('.app-status'))
  summaryHeight = $summary.outerHeight() ? 0
  statusHeight  = $status.outerHeight() ? 0

  rightSideBottomMargin = summaryHeight + statusHeight + ((context.ui.extras.visibleCount * extraHeight) + 1)

  $summary.css('bottom', "#{statusHeight}px")
  $('#right-side').css('margin-bottom', "#{rightSideBottomMargin}px")

reArrangeVisibleExtras = (context) ->
  visibleCount = 1
  for currentName of context.ui.extras
    if context.ui.extras[currentName]?.visibility
      context.ui.extras[currentName].$element.css('top', "-#{(visibleCount * extraHeight) + 1}px")
      visibleCount++

showExtra = (name, context) ->
  return if !context.ui.extras[name] || context.ui.extras[name].visibility
  context.ui.extras.visibleCount++
  context.ui.extras[name].visibility = true
  context.ui.extras[name].$element.show()

  reArrangeVisibleExtras(context)
  reMarginAppFooter(context)

hideExtra = (name, context) ->
  return if !context.ui.extras[name] || !context.ui.extras[name].visibility
  context.ui.extras.visibleCount--
  context.ui.extras[name].visibility = false
  context.ui.extras[name].$element.hide()

  reArrangeVisibleExtras(context)
  reMarginAppFooter(context)

#appTemplate có thêm hệ thống tooltip, auto-margin bottom.
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

      extras = @findAll(".row.extra")
      @ui.extras = { extrasCount: 0, visibleCount: 0 }
      for extra in extras
        $extra = $(extra)
        name = $extra.attr('name')
        visible = $extra.attr('visibility') ? false
        if $extra.attr('name')
          @ui.extras[name] = { key: $extra.attr('name'), visibility: visible, $element: $extra }
          $extra.show() if visible
          @ui.extras.extrasCount++
          @ui.extras.visibleCount++ if visible

      @ui.extras.show = (name) -> showExtra(name, self)
      @ui.extras.hide = (name) -> hideExtra(name, self)

      @$("[data-toggle='tooltip']").tooltip()
      for item in @findAll("[binding='datePicker']")
        $item = $(item)
        options = {}
        options.language = "vi"
        options.todayHighlight = true if $item.attr('todayHighlight') is "true"

        $(item).datepicker options

      $(item).attr('maxlength', 120) for item in @findAll("input:not([maxlength])")
      reMarginAppFooter(@)
      remarginAppHeader(@)

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