marginHandler = (context) ->
  $summary = $(context.find('.app-summary'))
  $status = $(context.find('.app-status'))
  summaryHeight = $summary.height() ? 0
  statusHeight  = $status.height() ? 0

  rightSideBottomMargin = summaryHeight + statusHeight

  $summary.css('bottom', "#{statusHeight}px")
  $('#right-side').css('margin-bottom', "#{rightSideBottomMargin}px")

#appTemplate có thêm hệ thống tooltip, auto-margin bottom.
class Sky.appTemplate
  @extends: (source, destination) ->
    exceptions = ['ui', 'rendered', 'destroyed']
    source[name] = value for name, value of destination when !_(exceptions).contains(name)

    rendered = ->
      if destination.ui
        @ui = {}
        @ui[name] = @find(value) for name, value of destination.ui when typeof value is 'string'

      @$("[data-toggle='tooltip']").tooltip()
      marginHandler(@)

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