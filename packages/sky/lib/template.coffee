class Sky.template
  @extends: (source, destination) ->
    exceptions = ['ui', 'rendered', 'destroyed']
    source[name] = value for name, value of destination when !_(exceptions).contains(name)

    rendered = ->
      if destination.ui
        @ui = {}
        @ui[name] = @find(value) for name, value of destination.ui when typeof value is 'string'

      @$("[data-toggle='tooltip']").tooltip()

      destination.rendered.apply(@, arguments) if destination.rendered

    destroyed = ->
      @$("[data-toggle='tooltip']").tooltip('destroy')

      destination.destroyed.apply(@, arguments) if destination.destroyed

    source.rendered = rendered
    source.destroyed = destroyed
    source

#var oldDoSomething = doSomething;
#doSomething = function() {
#// Do what you need to do.
#return oldDoSomething.apply(oldDoSomething, arguments);
#}